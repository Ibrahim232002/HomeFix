using System.Data;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.BLL.Services;

public class ServiceQuoteService : IServiceQuoteService
{
    private const string Draft = "Draft";
    private const string PendingCustomer = "PendingCustomer";
    private const string Accepted = "Accepted";
    private const string Rejected = "Rejected";
    private const string Expired = "Expired";
    private const string Cancelled = "Cancelled";
    private const string Superseded = "Superseded";

    private readonly ServiceQuoteRepository _quoteRepository;
    private readonly InspectionRepository _inspectionRepository;
    private readonly BookingRepository _bookingRepository;
    private readonly UnitOfWork _unitOfWork;

    public ServiceQuoteService(
        ServiceQuoteRepository quoteRepository,
        InspectionRepository inspectionRepository,
        BookingRepository bookingRepository,
        UnitOfWork unitOfWork)
    {
        _quoteRepository = quoteRepository;
        _inspectionRepository = inspectionRepository;
        _bookingRepository = bookingRepository;
        _unitOfWork = unitOfWork;
    }

    public Task<ServiceQuote?> GetByIdAsync(int id)
        => _quoteRepository.GetByIdAsync(id);

    public Task<List<ServiceQuote>> GetByInspectionIdAsync(int inspectionId)
        => _quoteRepository.GetByInspectionIdAsync(inspectionId);

    public async Task<(bool Success, string? Error, ServiceQuote? Quote)> CreateAsync(
        int technicianId,
        int inspectionId,
        decimal amount,
        string? notes,
        DateTime? expiresAt)
    {
        if (technicianId <= 0) return (false, "A valid technician is required.", null);
        if (inspectionId <= 0) return (false, "A valid inspection is required.", null);
        if (amount <= 0) return (false, "Quote amount must be greater than zero.", null);
        if (expiresAt.HasValue && expiresAt.Value <= DateTime.UtcNow)
            return (false, "Quote expiration must be in the future.", null);

        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var inspection = await _inspectionRepository.GetByIdAsync(inspectionId);
            if (inspection == null)
            {
                await tx.RollbackAsync();
                return (false, "Inspection not found.", null);
            }

            if (inspection.Status != "Completed")
            {
                await tx.RollbackAsync();
                return (false, "The inspection must be completed before creating a quote.", null);
            }

            if (inspection.TechnicianId != technicianId)
            {
                await tx.RollbackAsync();
                return (false, "You are not allowed to quote this inspection.", null);
            }

            var existingQuotes = await _quoteRepository.GetByInspectionIdAsync(inspectionId);
            if (existingQuotes.Count > 0)
            {
                await tx.RollbackAsync();
                return (false, "A quote already exists for this inspection. Create a new revision instead.", null);
            }

            var quote = new ServiceQuote
            {
                InspectionId = inspectionId,
                Amount = amount,
                Status = PendingCustomer,
                Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
                Revision = 1,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = expiresAt
            };

            await _quoteRepository.AddAsync(quote);
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null, await _quoteRepository.GetByIdAsync(quote.Id));
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The quote could not be created because the inspection was updated concurrently. Please retry.", null);
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }

    public async Task<(bool Success, string? Error, ServiceQuote? Quote)> CreateRevisionAsync(
        int technicianId,
        int quoteId,
        decimal amount,
        string? notes,
        DateTime? expiresAt)
    {
        if (technicianId <= 0) return (false, "A valid technician is required.", null);
        if (quoteId <= 0) return (false, "A valid quote is required.", null);
        if (amount <= 0) return (false, "Quote amount must be greater than zero.", null);
        if (expiresAt.HasValue && expiresAt.Value <= DateTime.UtcNow)
            return (false, "Quote expiration must be in the future.", null);

        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var quote = await _quoteRepository.GetByIdAsync(quoteId);
            if (quote == null)
            {
                await tx.RollbackAsync();
                return (false, "Quote not found.", null);
            }

            var inspection = quote.Inspection;
            if (inspection.Status != "Completed")
            {
                await tx.RollbackAsync();
                return (false, "The inspection must be completed before creating a quote revision.", null);
            }

            if (inspection.TechnicianId != technicianId)
            {
                await tx.RollbackAsync();
                return (false, "You are not allowed to revise this quote.", null);
            }

            var allQuotes = await _quoteRepository.GetByInspectionIdAsync(inspection.Id);
            var now = DateTime.UtcNow;

            var activePending = allQuotes.FirstOrDefault(q => q.Status == PendingCustomer);
            if (activePending != null)
            {
                if (activePending.ExpiresAt.HasValue && activePending.ExpiresAt.Value <= now)
                {
                    activePending.Status = Expired;
                    _quoteRepository.Update(activePending);
                }
                else
                {
                    await tx.RollbackAsync();
                    return (false, "An active customer quote already exists for this inspection.", null);
                }
            }

            var nextRevision = allQuotes.Count == 0 ? 1 : allQuotes.Max(q => q.Revision) + 1;
            var newQuote = new ServiceQuote
            {
                InspectionId = inspection.Id,
                Amount = amount,
                Status = PendingCustomer,
                Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
                Revision = nextRevision,
                CreatedAt = now,
                ExpiresAt = expiresAt
            };

            await _quoteRepository.AddAsync(newQuote);
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null, await _quoteRepository.GetByIdAsync(newQuote.Id));
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The quote revision could not be created because the inspection was updated concurrently. Please retry.", null);
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }

    public async Task<(bool Success, string? Error)> AcceptAsync(int quoteId, int customerUserId)
    {
        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var quote = await _quoteRepository.GetByIdAsync(quoteId);
            if (quote == null)
            {
                await tx.RollbackAsync();
                return (false, "Quote not found.");
            }

            if (quote.Inspection.Status != "Completed")
            {
                await tx.RollbackAsync();
                return (false, "The inspection is not completed.");
            }

            if (quote.Inspection.ServiceRequest.Customer.UserId != customerUserId)
            {
                await tx.RollbackAsync();
                return (false, "You are not allowed to accept this quote.");
            }

            var currentQuote = await _quoteRepository.GetByIdAsync(quoteId);
            if (currentQuote == null || currentQuote.Status != PendingCustomer)
            {
                await tx.RollbackAsync();
                return (false, "Quote is no longer available.");
            }

            if (currentQuote.ExpiresAt.HasValue && currentQuote.ExpiresAt.Value <= DateTime.UtcNow)
            {
                currentQuote.Status = Expired;
                _quoteRepository.Update(currentQuote);
                await _unitOfWork.SaveChangesAsync();
                await tx.CommitAsync();
                return (false, "Quote has expired.");
            }

            var request = currentQuote.Inspection.ServiceRequest;
            var existingBooking = await _bookingRepository.GetByRequestIdAsync(request.Id);
            if (existingBooking != null)
            {
                await tx.RollbackAsync();
                return (false, "This request already has a booking.");
            }

            currentQuote.Status = Accepted;
            _quoteRepository.Update(currentQuote);

            var otherQuotes = await _quoteRepository.GetByInspectionIdAsync(currentQuote.InspectionId);
            foreach (var other in otherQuotes.Where(q => q.Id != currentQuote.Id && q.Status == PendingCustomer))
            {
                other.Status = Superseded;
                _quoteRepository.Update(other);
            }

            await _bookingRepository.AddAsync(new Booking
            {
                ServiceRequestId = request.Id,
                TechnicianId = currentQuote.Inspection.TechnicianId,
                Status = "Confirmed",
                AgreedPrice = currentQuote.Amount,
                FinalPrice = null,
                AcceptedAt = DateTime.UtcNow
            });

            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The quote could not be accepted because the request was updated concurrently. Please retry.");
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }

    public async Task<(bool Success, string? Error)> RejectAsync(int quoteId, int customerUserId)
    {
        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var quote = await _quoteRepository.GetByIdAsync(quoteId);
            if (quote == null)
            {
                await tx.RollbackAsync();
                return (false, "Quote not found.");
            }

            if (quote.Inspection.Status != "Completed")
            {
                await tx.RollbackAsync();
                return (false, "The inspection is not completed.");
            }

            if (quote.Inspection.ServiceRequest.Customer.UserId != customerUserId)
            {
                await tx.RollbackAsync();
                return (false, "You are not allowed to reject this quote.");
            }

            var currentQuote = await _quoteRepository.GetByIdAsync(quoteId);
            if (currentQuote == null || currentQuote.Status != PendingCustomer)
            {
                await tx.RollbackAsync();
                return (false, "Quote is no longer available.");
            }

            if (currentQuote.ExpiresAt.HasValue && currentQuote.ExpiresAt.Value <= DateTime.UtcNow)
            {
                currentQuote.Status = Expired;
                _quoteRepository.Update(currentQuote);
                await _unitOfWork.SaveChangesAsync();
                await tx.CommitAsync();
                return (false, "Quote has expired.");
            }

            currentQuote.Status = Rejected;
            _quoteRepository.Update(currentQuote);
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The quote could not be rejected because the request was updated concurrently. Please retry.");
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }
}
