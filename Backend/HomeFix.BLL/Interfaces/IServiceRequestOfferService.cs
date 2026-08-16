using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceRequestOfferService
{
    Task<List<ServiceRequestOffer>> GetByRequestIdAsync(int requestId);
    Task<List<ServiceRequestOffer>> GetByTechnicianIdAsync(int technicianId);
    Task<(bool Success, string? Error, ServiceRequestOffer? Offer)> CreateAsync(int requestId, int technicianId, decimal proposedPrice, string? note);
    Task<(bool Success, string? Error)> AcceptAsync(int offerId, int customerProfileId);
    Task<(bool Success, string? Error)> RejectAsync(int offerId, int customerProfileId);
}
