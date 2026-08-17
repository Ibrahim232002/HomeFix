using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceRequestRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceRequestRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<ServiceRequest?> GetByIdAsync(int id)
    {
        return await _context.ServiceRequests
            .Include(r => r.Customer)
            .Include(r => r.Service)
            .Include(r => r.Address)
                .ThenInclude(a => a.City)
            .Include(r => r.Address)
                .ThenInclude(a => a.Governorate)
            .Include(r => r.Booking)
            .Include(r => r.UserPromoCode)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<List<ServiceRequest>> GetByCustomerIdAsync(int customerId)
    {
        return await _context.ServiceRequests
            .Include(r => r.Service)
            .Include(r => r.Address)
                .ThenInclude(a => a.City)
            .Include(r => r.Address)
                .ThenInclude(a => a.Governorate)
            .Where(r => r.CustomerId == customerId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<ServiceRequest>> GetByStatusAsync(string status)
    {
        return await _context.ServiceRequests
            .Include(r => r.Service)
            .Include(r => r.Address)
                .ThenInclude(a => a.City)
            .Include(r => r.Address)
                .ThenInclude(a => a.Governorate)
            .Where(r => r.Status == status)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<ServiceRequest>> GetPendingForTechnicianAsync(int technicianId)
    {
        return await _context.ServiceRequests
            .Include(r => r.Service)
            .Include(r => r.Address)
                .ThenInclude(a => a.City)
            .Include(r => r.Address)
                .ThenInclude(a => a.Governorate)
            .Where(r => r.Status == "Pending" || r.Status == "Open" || r.Status == "OfferPending")
            .Where(r => r.Address.CityId != null)
            .Where(r => _context.TechnicianProfiles.Any(t =>
                t.Id == technicianId && t.User.IsActive && t.IsVerified && t.IsAvailable &&
                t.Services.Any(s => s.Id == r.ServiceId) &&
                t.TechnicianServiceAreas.Any(a => a.CityId == r.Address.CityId)))
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(ServiceRequest request)
    {
        await _context.ServiceRequests.AddAsync(request);
    }

    public async Task UpdateAsync(ServiceRequest request)
    {
        _context.ServiceRequests.Update(request);
    }
}