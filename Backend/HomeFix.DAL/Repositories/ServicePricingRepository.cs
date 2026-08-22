using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServicePricingRepository
{
    private readonly HomeFixDbContext _context;

    public ServicePricingRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<ServicePricing?> GetAsync(int serviceId, int cityId)
    {
        return await _context.ServicePricings
            .FirstOrDefaultAsync(p =>
                p.ServiceId == serviceId &&
                p.CityId == cityId);
    }

    public async Task<List<ServicePricing>> GetByServiceIdAsync(int serviceId)
    {
        return await _context.ServicePricings
            .Where(p => p.ServiceId == serviceId && p.IsActive)
            .ToListAsync();
    }

    public async Task AddAsync(ServicePricing pricing)
    {
        await _context.ServicePricings.AddAsync(pricing);
    }

    public async Task UpdateAsync(ServicePricing pricing)
    {
        _context.ServicePricings.Update(pricing);
    }
}