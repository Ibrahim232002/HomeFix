using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Enums;
using HomeFix.DAL.Repositories;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace HomeFix.BLL.Services;

public class InspectionService : IInspectionService
{
    private const string Scheduled = "Scheduled";
    private const string InProgress = "InProgress";
    private const string Completed = "Completed";
    private const string Cancelled = "Cancelled";
    private const string NoShow = "NoShow";

    private readonly InspectionRepository _inspectionRepository;
    private readonly ServiceRequestRepository _requestRepository;
    private readonly ServiceRequestOfferRepository _offerRepository;
    private readonly ServicePricingService _pricingService;
    private readonly UnitOfWork _unitOfWork;

    public InspectionService(
        InspectionRepository inspectionRepository,
        ServiceRequestRepository requestRepository,
        ServiceRequestOfferRepository offerRepository,
        ServicePricingService pricingService,
        UnitOfWork unitOfWork)
    {
        _inspectionRepository = inspectionRepository;
        _requestRepository = requestRepository;
        _offerRepository = offerRepository;
        _pricingService = pricingService;
        _unitOfWork = unitOfWork;
    }

    public Task<Inspection?> GetByIdAsync(int id)
        => _inspectionRepository.GetByIdAsync(id);

    public Task<Inspection?> GetByRequestIdAsync(int serviceRequestId)
        => _inspectionRepository.GetByRequestIdAsync(serviceRequestId);

    public Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId)
        => _inspectionRepository.GetByTechnicianIdAsync(technicianId);

    public async Task<(bool Success, string? Error, Inspection? Inspection)> CreateAsync(
        int technicianId,
        int serviceRequestId,
        DateTime scheduledAt)
    {
        if (technicianId <= 0) return (false, "A valid technician is required.", null);
        if (serviceRequestId <= 0) return (false, "A valid service request is required.", null);
        if (scheduledAt <= DateTime.UtcNow) return (false, "Inspection must be scheduled for a future time.", null);

        var request = await _requestRepository.GetByIdAsync(serviceRequestId);
        if (request == null) return (false, "Service request not found.", null);
        if (request.Inspection != null) return (false, "An inspection already exists for this service request.", null);
        if (request.Status != "Accepted") return (false, "The service request is not ready for inspection.", null);
        if (!Enum.IsDefined(request.Service.PricingMode)) return (false, "Service pricing mode is invalid.", null);
        if (request.Service.PricingMode != PricingMode.Inspection) return (false, "This service does not use inspection pricing.", null);

        var acceptedOffer = (await _offerRepository.GetByRequestIdAsync(serviceRequestId))
            .FirstOrDefault(x => x.Status == "Accepted");
        if (acceptedOffer == null) return (false, "An accepted technician offer is required before creating an inspection.", null);
        if (acceptedOffer.TechnicianId != technicianId) return (false, "Technician is not the selected technician for this request.", null);

        var pricing = await _pricingService.GetForServiceAsync(request.ServiceId, request.Address.CityId);
        if (pricing == null) return (false, "No active pricing is configured for this service and location.", null);
        if (!pricing.InspectionFee.HasValue) return (false, "Inspection fee is not configured for this service and location.", null);

        var inspection = new Inspection
        {
            ServiceRequestId = request.Id,
            TechnicianId = acceptedOffer.TechnicianId,
            Fee = pricing.InspectionFee.Value,
            ScheduledAt = scheduledAt,
            Status = Scheduled,
            Findings = null,
            CreatedAt = DateTime.UtcNow,
            CompletedAt = null
        };

        try
        {
            await _inspectionRepository.AddAsync(inspection);
            await _unitOfWork.SaveChangesAsync();
        }
        catch (DbUpdateException ex) when (IsDuplicateInspectionException(ex))
        {
            return (false, "An inspection already exists for this service request.", null);
        }

        return (true, null, await _inspectionRepository.GetByIdAsync(inspection.Id));
    }

    public Task<(bool Success, string? Error, Inspection? Inspection)> ScheduleAsync(int technicianId, int inspectionId, DateTime scheduledAt)
    {
        if (scheduledAt <= DateTime.UtcNow)
            return Task.FromResult<(bool Success, string? Error, Inspection? Inspection)>((false, "Inspection must be scheduled for a future time.", null));

        return TransitionAsync(technicianId, inspectionId, Scheduled, inspection => inspection.ScheduledAt = scheduledAt);
    }

    public Task<(bool Success, string? Error, Inspection? Inspection)> StartAsync(int technicianId, int inspectionId)
        => TransitionAsync(technicianId, inspectionId, InProgress, null);

    public async Task<(bool Success, string? Error, Inspection? Inspection)> CompleteAsync(
        int technicianId,
        int inspectionId,
        string findings)
    {
        if (string.IsNullOrWhiteSpace(findings))
            return (false, "Findings are required to complete the inspection.", null);

        return await TransitionAsync(technicianId, inspectionId, Completed, inspection =>
        {
            inspection.Findings = findings.Trim();
            inspection.CompletedAt = DateTime.UtcNow;
        });
    }

    public Task<(bool Success, string? Error, Inspection? Inspection)> CancelAsync(int technicianId, int inspectionId)
        => TransitionAsync(technicianId, inspectionId, Cancelled, null);

    public Task<(bool Success, string? Error, Inspection? Inspection)> NoShowAsync(int technicianId, int inspectionId)
        => TransitionAsync(technicianId, inspectionId, NoShow, null);

    private async Task<(bool Success, string? Error, Inspection? Inspection)> TransitionAsync(
        int technicianId,
        int inspectionId,
        string targetStatus,
        Action<Inspection>? apply)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var inspection = await _inspectionRepository.GetByIdAsync(inspectionId);
            if (inspection == null) return (false, "Inspection not found.", null);
            if (inspection.TechnicianId != technicianId) return (false, "You are not allowed to modify this inspection.", null);

            var allowed = targetStatus switch
            {
                Scheduled => inspection.Status == Scheduled,
                InProgress => inspection.Status == Scheduled,
                Completed => inspection.Status == InProgress,
                Cancelled => inspection.Status is Scheduled or InProgress,
                NoShow => inspection.Status == Scheduled,
                _ => false
            };

            if (!allowed)
                return (false, $"Invalid inspection status transition from {inspection.Status} to {targetStatus}.", null);

            apply?.Invoke(inspection);
            inspection.Status = targetStatus;
            _inspectionRepository.Update(inspection);
            await _unitOfWork.SaveChangesAsync();
            await transaction.CommitAsync();

            return (true, null, await _inspectionRepository.GetByIdAsync(inspection.Id));
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    private static bool IsDuplicateInspectionException(DbUpdateException exception)
    {
        if (exception.GetBaseException() is not SqlException sqlException)
            return false;

        return sqlException.Number is 2601 or 2627;
    }
}
