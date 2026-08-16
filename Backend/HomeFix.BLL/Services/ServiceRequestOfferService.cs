using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

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
        var request = await _requestRepository.GetByIdAsync(requestId);
        if (request == null) return (false, "Service request not found.", null);
        if (request.Status is not ("Pending" or "Open" or "OfferPending")) return (false, "This request is not accepting offers.", null);
        if (!await _technicianRepository.IsEligibleForRequestAsync(technicianId, request.ServiceId, request.Address.CityId)) return (false, "Technician is not eligible for this request.", null);
        if (await _offerRepository.ExistsForTechnicianAsync(requestId, technicianId)) return (false, "Technician already has a pending offer for this request.", null);
        var offer = new ServiceRequestOffer { ServiceRequestId = requestId, TechnicianId = technicianId, ProposedPrice = proposedPrice, TechnicianNote = note, Status = "Pending", CreatedAt = DateTime.UtcNow, ExpiresAt = DateTime.UtcNow.AddHours(24) };
        await _offerRepository.AddAsync(offer);
        if (request.Status == "Open" || request.Status == "Pending") request.Status = "OfferPending";
        request.UpdatedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return (true, null, offer);
    }

    public async Task<(bool Success, string? Error)> AcceptAsync(int offerId, int customerUserId)
    {
        var offer = await _offerRepository.GetByIdAsync(offerId);
        if (offer == null) return (false, "Offer not found.");
        if (offer.ServiceRequest.Customer.UserId != customerUserId) return (false, "You are not allowed to accept this offer.");
        if (offer.Status != "Pending") return (false, "Offer is no longer available.");
        if (offer.ExpiresAt.HasValue && offer.ExpiresAt <= DateTime.UtcNow) return (false, "Offer has expired.");
        await using var tx = await _unitOfWork.BeginTransactionAsync();
        var existingBooking = await _bookingRepository.GetByRequestIdAsync(offer.ServiceRequestId);
        if (existingBooking != null) return (false, "This request already has a booking.");
        offer.Status = "Accepted"; offer.RespondedAt = DateTime.UtcNow;
        var otherOffers = await _offerRepository.GetByRequestIdAsync(offer.ServiceRequestId);
        foreach (var other in otherOffers.Where(x => x.Id != offer.Id && x.Status == "Pending")) { other.Status = "Rejected"; other.RespondedAt = DateTime.UtcNow; }
        offer.ServiceRequest.Status = "Accepted"; offer.ServiceRequest.UpdatedAt = DateTime.UtcNow;
        await _bookingRepository.AddAsync(new Booking { ServiceRequestId = offer.ServiceRequestId, TechnicianId = offer.TechnicianId, Status = "Confirmed", AgreedPrice = offer.ProposedPrice, FinalPrice = null, AcceptedAt = DateTime.UtcNow });
        await _unitOfWork.SaveChangesAsync();
        await tx.CommitAsync();
        return (true, null);
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
