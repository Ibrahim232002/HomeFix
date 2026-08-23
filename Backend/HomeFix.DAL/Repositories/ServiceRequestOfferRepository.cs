using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceRequestOfferRepository
{
    private readonly HomeFixDbContext _context;
    public ServiceRequestOfferRepository(HomeFixDbContext context) => _context = context;

    public Task<ServiceRequestOffer?> GetByIdAsync(int id) =>
        _context.ServiceRequestOffers.Include(x => x.ServiceRequest).ThenInclude(r => r.Customer).Include(x => x.ServiceRequest).ThenInclude(r => r.Service).Include(x => x.Technician).FirstOrDefaultAsync(x => x.Id == id);

    public Task<List<ServiceRequestOffer>> GetByRequestIdAsync(int requestId) =>
        _context.ServiceRequestOffers
            .Include(x => x.ServiceRequest)
            .ThenInclude(r => r.Service)
            .Include(x => x.Technician)
            .ThenInclude(t => t.User)
            .Where(x => x.ServiceRequestId == requestId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

    public Task<List<ServiceRequestOffer>> GetByTechnicianIdAsync(int technicianId) =>
        _context.ServiceRequestOffers.Include(x => x.ServiceRequest).ThenInclude(r => r.Service).Where(x => x.TechnicianId == technicianId).OrderByDescending(x => x.CreatedAt).ToListAsync();

    public Task<bool> ExistsForTechnicianAsync(int requestId, int technicianId) =>
        _context.ServiceRequestOffers.AnyAsync(x => x.ServiceRequestId == requestId && x.TechnicianId == technicianId && x.Status == "Pending");

    public Task AddAsync(ServiceRequestOffer offer) => _context.ServiceRequestOffers.AddAsync(offer).AsTask();
    public void Update(ServiceRequestOffer offer) => _context.ServiceRequestOffers.Update(offer);
}
