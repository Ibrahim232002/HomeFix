using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Enums;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class InspectionService : IInspectionService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly InspectionRepository _repository;
    private readonly ServiceRequestRepository _requestRepository;
    private readonly ServicePricingRepository _pricingRepository;

    public InspectionService(
        InspectionRepository repository,
        ServiceRequestRepository requestRepository,
        ServicePricingRepository pricingRepository,
        UnitOfWork unitOfWork)
    {
        _repository = repository;
        _requestRepository = requestRepository;
        _pricingRepository = pricingRepository;
        _unitOfWork = unitOfWork;
    }

    public Task<Inspection?> GetByIdAsync(int id) => _repository.GetByIdAsync(id);
    public Task<Inspection?> GetByRequestIdAsync(int requestId) => _repository.GetByRequestIdAsync(requestId);
    public Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId) => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task<(bool Success, string? Error, Inspection? Inspection)> CreateForAcceptedOfferAsync(int requestId, int technicianId)
    {
        var existing = await _repository.GetByRequestIdAsync(requestId);
        if (existing != null)
            return (false, "An inspection already exists for this service request.", existing);

        var request = await _requestRepository.GetByIdAsync(requestId);
        if (request == null) return (false, "Service request not found.", null);
        if (request.Status != "Accepted") return (false, "The service request must be accepted before an inspection is created.", null);
        if (request.Service.PricingMode != PricingMode.Inspection)
            return (false, "This service does not use inspection pricing.", null);
        if (request.Booking != null) return (false, "A booking already exists for this service request.", null);
        if (!request.PreferredDate.HasValue || !request.PreferredTime.HasValue)
            return (false, "A preferred date and time are required to schedule the inspection.", null);

        var pricing = await _pricingRepository.GetForServiceAsync(request.ServiceId, request.Address.CityId);
        if (pricing?.InspectionFee == null)
            return (false, "Inspection pricing is not configured for this service and location.", null);

        var localDateTime = request.PreferredDate.Value.ToDateTime(request.PreferredTime.Value);
        var scheduledAt = DateTime.SpecifyKind(localDateTime, DateTimeKind.Utc);
        var inspection = new Inspection
        {
            ServiceRequestId = request.Id,
            TechnicianId = technicianId,
            Fee = pricing.InspectionFee.Value,
            ScheduledAt = scheduledAt,
            Status = "Scheduled",
            CreatedAt = DateTime.UtcNow
        };

        await _repository.AddAsync(inspection);
        await _unitOfWork.SaveChangesAsync();
        return (true, null, inspection);
    }

    public async Task<(bool Success, string? Error)> ScheduleAsync(int inspectionId, int technicianId, DateTime scheduledAt)
    {
        var inspection = await _repository.GetByIdAsync(inspectionId);
        if (inspection == null) return (false, "Inspection not found.");
        if (inspection.TechnicianId != technicianId) return (false, "You are not allowed to modify this inspection.");
        if (inspection.Status is "Completed" or "Cancelled" or "NoShow") return (false, "This inspection can no longer be rescheduled.");
        inspection.ScheduledAt = scheduledAt.ToUniversalTime();
        inspection.Status = "Scheduled";
        _repository.Update(inspection);
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }

    public Task<(bool Success, string? Error)> StartAsync(int inspectionId, int technicianId)
        => TransitionAsync(inspectionId, technicianId, "InProgress", null);

    public async Task<(bool Success, string? Error)> CompleteAsync(int inspectionId, int technicianId, string? findings)
    {
        var result = await TransitionAsync(inspectionId, technicianId, "Completed", findings);
        return result;
    }

    public Task<(bool Success, string? Error)> CancelAsync(int inspectionId, int technicianId)
        => TransitionAsync(inspectionId, technicianId, "Cancelled", null);

    public Task<(bool Success, string? Error)> NoShowAsync(int inspectionId, int technicianId)
        => TransitionAsync(inspectionId, technicianId, "NoShow", null);

    private async Task<(bool Success, string? Error)> TransitionAsync(int inspectionId, int technicianId, string newStatus, string? findings)
    {
        var inspection = await _repository.GetByIdAsync(inspectionId);
        if (inspection == null) return (false, "Inspection not found.");
        if (inspection.TechnicianId != technicianId) return (false, "You are not allowed to modify this inspection.");

        var allowed = inspection.Status switch
        {
            "Scheduled" => newStatus is "InProgress" or "Cancelled" or "NoShow",
            "InProgress" => newStatus is "Completed" or "Cancelled" or "NoShow",
            _ => false
        };
        if (!allowed) return (false, $"Invalid inspection status transition from {inspection.Status} to {newStatus}.");

        inspection.Status = newStatus;
        if (!string.IsNullOrWhiteSpace(findings)) inspection.Findings = findings.Trim();
        if (newStatus == "Completed") inspection.CompletedAt = DateTime.UtcNow;
        _repository.Update(inspection);
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }
}
