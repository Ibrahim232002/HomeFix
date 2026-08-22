using System.Data;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.BLL.Services;

public class ServiceQuoteService : IServiceQuoteService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly ServiceQuoteRepository _repository;
    private readonly InspectionRepository _inspectionRepository;
    private readonly BookingRepository _bookingRepository;

    public ServiceQuoteService(
        ServiceQuoteRepository repository,
        InspectionRepository inspectionRepository,
        BookingRepository bookingRepository,
        UnitOfWork unitOfWork)
    {
        _repository = repository;
        _inspectionRepository = inspectionRepository;
        _bookingRepository = bookingRepository;
        _unitOfWork = unitOfWork;
    }

    public Task<ServiceQuote?> GetByIdAsync(int id) => _repository.GetByIdAsync(id);

    public Task<List<ServiceQuote>> GetByInspectionIdAsync(int inspectionId) =>
        _repository.GetByInspectionIdAsync(inspectionId);

    public async Task<(bool Success, string? Error, ServiceQuote? Quote)> CreateAsync(
        int inspectionId,
        int technicianId,
        decimal amount,
        string? notes,
        DateTime? expiresAt)
    {
        if (amount <= 0) return (false, "Quote amount must be greater than zero.", null);

        var inspection = await _inspectionRepository.GetByIdAsync(inspectionId);
        if (inspection == null) return (false, "Inspection not found.", null);
        if (inspection.TechnicianId != technicianId) return (false, "You are not allowed to quote this inspection.", null);
        if (inspection.Status != "Completed") return (false, "A quote can only be created after the inspection is completed.", null);
        if (await _bookingRepository.GetByRequestIdAsync(inspection.ServiceRequestId) != null)
            return (false, "This request already has a booking.", null);

        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var currentPending = await _repository.GetPendingAsync(inspectionId);
            if (currentPending != null)
            {
                currentPending.Status = "Superseded";
                _repository.Update(currentPending);
            }

            var revision = await _repository.GetNextRevisionAsync(inspectionId);
            var quote = new ServiceQuote
            {
                InspectionId = inspectionId,
                Amount = amount,
                Status = "PendingCustomer",
                Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
                Revision = revision,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = expiresAt?.ToUniversalTime()
            };
            await _repository.AddAsync(quote);
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null, quote);
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
        int quoteId,
        int technicianId,
        decimal amount,
        string? notes,
        DateTime? expiresAt)
    {
        var current = await _repository.GetByIdAsync(quoteId);
        if (current == null) return (false, "Quote not found.", null);
        if (current.Inspection.TechnicianId != technicianId) return (false, "You are not allowed to revise this quote.", null);
        if (current.Status == "Accepted") return (false, "An accepted quote cannot be revised.", null);
        return await CreateAsync(current.InspectionId, technicianId, amount, notes, expiresAt);
    }

    public async Task<(bool Success, string? Error)> AcceptAsync(int quoteId, int customerUserId)
    {
        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var quote = await _repository.GetByIdAsync(quoteId);
            if (quote == null) { await tx.RollbackAsync(); return (false, "Quote not found."); }
            if (quote.Inspection.ServiceRequest.Customer.UserId != customerUserId)
            {
                await tx.RollbackAsync();
                return (false, "You are not allowed to accept this quote.");
            }
            if (quote.Status != "PendingCustomer")
            {
                await tx.RollbackAsync();
                return (false, "Quote is no longer available.");
            }
            if (quote.ExpiresAt.HasValue && quote.ExpiresAt.Value <= DateTime.UtcNow)
            {
                quote.Status = "Expired";
                _repository.Update(quote);
                await _unitOfWork.SaveChangesAsync();
                await tx.CommitAsync();
                return (false, "Quote has expired.");
            }
            if (quote.Inspection.Status != "Completed")
            {
                await tx.RollbackAsync();
                return (false, "The inspection must be completed before accepting the quote.");
            }

            var existingBooking = await _bookingRepository.GetByRequestIdAsync(quote.Inspection.ServiceRequestId);
            if (existingBooking != null)
            {
                await tx.RollbackAsync();
                return (false, "This request already has a booking.");
            }

            var currentQuote = await _repository.GetByIdAsync(quoteId);
            if (currentQuote == null || currentQuote.Status != "PendingCustomer")
            {
                await tx.RollbackAsync();
                return (false, "Quote is no longer available.");
            }

            currentQuote.Status = "Accepted";
            var allQuotes = await _repository.GetByInspectionIdAsync(currentQuote.InspectionId);
            foreach (var other in allQuotes.Where(x => x.Id != currentQuote.Id && x.Status == "PendingCustomer"))
                other.Status = "Superseded";

            currentQuote.Inspection.ServiceRequest.Status = "Accepted";
            currentQuote.Inspection.ServiceRequest.UpdatedAt = DateTime.UtcNow;
            await _bookingRepository.AddAsync(new Booking
            {
                ServiceRequestId = currentQuote.Inspection.ServiceRequestId,
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
        var quote = await _repository.GetByIdAsync(quoteId);
        if (quote == null) return (false, "Quote not found.");
        if (quote.Inspection.ServiceRequest.Customer.UserId != customerUserId)
            return (false, "You are not allowed to reject this quote.");
        if (quote.Status != "PendingCustomer") return (false, "Quote is no longer pending.");
        if (quote.ExpiresAt.HasValue && quote.ExpiresAt.Value <= DateTime.UtcNow)
        {
            quote.Status = "Expired";
            _repository.Update(quote);
            await _unitOfWork.SaveChangesAsync();
            return (false, "Quote has expired.");
        }

        quote.Status = "Rejected";
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }
}
