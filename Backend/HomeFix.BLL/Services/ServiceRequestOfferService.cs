using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Enums;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace HomeFix.BLL.Services;

public class ServiceRequestOfferService : IServiceRequestOfferService
{
    private readonly ServiceRequestOfferRepository _offerRepository;
    private readonly ServiceRequestRepository _requestRepository;
    private readonly BookingRepository _bookingRepository;
    private readonly TechnicianProfileRepository _technicianRepository;
    private readonly UnitOfWork _unitOfWork;

    public ServiceRequestOfferService(ServiceRequestOfferRepository offerRepository, ServiceRequestRepository requestRepository, BookingRepository bookingRepository, TechnicianProfileRepository technicianRepository, UnitOfWork unitOfWork)
    {
        _offerRepository = offerRepository; _requestRepository = requestRepository; _bookingRepository = bookingRepository; _technicianRepository = technicianRepository; _unitOfWork = unitOfWork;
    }

    public Task<List<ServiceRequestOffer>> GetByRequestIdAsync(int requestId) => _offerRepository.GetByRequestIdAsync(requestId);
    public Task<List<ServiceRequestOffer>> GetByTechnicianIdAsync(int technicianId) => _offerRepository.GetByTechnicianIdAsync(technicianId);

    public async Task<(bool Success, string? Error, ServiceRequestOffer? Offer)> CreateAsync(int requestId, int technicianId, decimal proposedPrice, string? note)
    {
        if (proposedPrice <= 0) return (false, "Proposed price must be greater than zero.", null);

        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var request = await _requestRepository.GetByIdAsync(requestId);
            if (request == null)
            {
                await tx.RollbackAsync();
                return (false, "Service request not found.", null);
            }

            if (request.Status is not ("Pending" or "Open" or "OfferPending"))
            {
                await tx.RollbackAsync();
                return (false, "This request is not accepting offers.", null);
            }

            if (!await _technicianRepository.IsEligibleForRequestAsync(technicianId, request.ServiceId, request.Address.CityId))
            {
                await tx.RollbackAsync();
                return (false, "Technician is not eligible for this request.", null);
            }

            // Re-check inside the serialized transaction so concurrent submissions
            // cannot create duplicate pending offers for the same technician/request pair.
            if (await _offerRepository.ExistsForTechnicianAsync(requestId, technicianId))
            {
                await tx.RollbackAsync();
                return (false, "Technician already has a pending offer for this request.", null);
            }

            var offer = new ServiceRequestOffer
            {
                ServiceRequestId = requestId,
                TechnicianId = technicianId,
                ProposedPrice = proposedPrice,
                TechnicianNote = note,
                Status = "Pending",
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddHours(24)
            };

            await _offerRepository.AddAsync(offer);
            if (request.Status == "Open" || request.Status == "Pending") request.Status = "OfferPending";
            request.UpdatedAt = DateTime.UtcNow;
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null, offer);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The offer could not be created because the request was updated concurrently. Please retry.", null);
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }

    public async Task<(bool Success, string? Error)> AcceptAsync(int offerId, int customerUserId)
    {
        var offer = await _offerRepository.GetByIdAsync(offerId);
        if (offer == null) return (false, "Offer not found.");
        if (offer.ServiceRequest.Customer.UserId != customerUserId) return (false, "You are not allowed to accept this offer.");
        if (offer.Status != "Pending") return (false, "Offer is no longer available.");
        if (offer.ExpiresAt.HasValue && offer.ExpiresAt <= DateTime.UtcNow) return (false, "Offer has expired.");

        await using var tx = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var request = offer.ServiceRequest;
            var pricingMode = request.Service.PricingMode;

            var existingBooking = await _bookingRepository.GetByRequestIdAsync(request.Id);
            if (existingBooking != null)
            {
                await tx.RollbackAsync();
                return (false, "This request already has a booking.");
            }

            // Re-read the offer inside the serialized transaction so concurrent acceptance
            // cannot leave more than one accepted offer/booking for the same request.
            var currentOffer = await _offerRepository.GetByIdAsync(offerId);
            if (currentOffer == null || currentOffer.Status != "Pending")
            {
                await tx.RollbackAsync();
                return (false, "Offer is no longer available.");
            }
            if (currentOffer.ExpiresAt.HasValue && currentOffer.ExpiresAt <= DateTime.UtcNow)
            {
                await tx.RollbackAsync();
                return (false, "Offer has expired.");
            }

            // Inspection requests select a technician at offer acceptance time but do not
            // create a Booking until the completed inspection quote is accepted.
            if (pricingMode == PricingMode.Inspection)
            {
                var acceptedOffer = (await _offerRepository.GetByRequestIdAsync(currentOffer.ServiceRequestId))
                    .FirstOrDefault(x => x.Status == "Accepted" && x.Id != currentOffer.Id);
                if (acceptedOffer != null)
                {
                    await tx.RollbackAsync();
                    return (false, "This request already has an accepted technician offer.");
                }
            }

            currentOffer.Status = "Accepted";
            currentOffer.RespondedAt = DateTime.UtcNow;
            var otherOffers = await _offerRepository.GetByRequestIdAsync(currentOffer.ServiceRequestId);
            foreach (var other in otherOffers.Where(x => x.Id != currentOffer.Id && x.Status == "Pending"))
            {
                other.Status = "Rejected";
                other.RespondedAt = DateTime.UtcNow;
            }

            currentOffer.ServiceRequest.Status = "Accepted";
            currentOffer.ServiceRequest.UpdatedAt = DateTime.UtcNow;

            if (pricingMode != PricingMode.Inspection)
            {
                await _bookingRepository.AddAsync(new Booking
                {
                    ServiceRequestId = currentOffer.ServiceRequestId,
                    TechnicianId = currentOffer.TechnicianId,
                    Status = "Confirmed",
                    AgreedPrice = currentOffer.ProposedPrice,
                    FinalPrice = null,
                    AcceptedAt = DateTime.UtcNow
                });
            }

            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
            return (true, null);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            return (false, "The offer could not be accepted because the request was updated concurrently. Please retry.");
        }
    }

    public async Task<(bool Success, string? Error)> RejectAsync(int offerId, int customerUserId)
    {
        var offer = await _offerRepository.GetByIdAsync(offerId);
        if (offer == null) return (false, "Offer not found.");
        if (offer.ServiceRequest.Customer.UserId != customerUserId) return (false, "You are not allowed to reject this offer.");
        if (offer.Status != "Pending") return (false, "Offer is no longer pending.");
        offer.Status = "Rejected"; offer.RespondedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }
}
