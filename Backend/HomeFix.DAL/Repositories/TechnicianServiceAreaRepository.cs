using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class TechnicianServiceAreaRepository
{
    private readonly HomeFixDbContext _context;

    public TechnicianServiceAreaRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<TechnicianServiceArea>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.TechnicianServiceAreas
            .Include(a => a.City)
            .Where(a => a.TechnicianId == technicianId)
            .ToListAsync();
    }

    public async Task<List<TechnicianServiceArea>> GetByCityIdAsync(int cityId)
    {
        return await _context.TechnicianServiceAreas
            .Where(a => a.CityId == cityId)
            .ToListAsync();
    }

    public async Task AddAsync(TechnicianServiceArea area)
    {
        await _context.TechnicianServiceAreas.AddAsync(area);
    }

    public async Task DeleteAsync(TechnicianServiceArea area)
    {
        _context.TechnicianServiceAreas.Remove(area);
    }
}