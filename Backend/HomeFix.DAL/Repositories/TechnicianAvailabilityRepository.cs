using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class TechnicianAvailabilityRepository
{
    private readonly HomeFixDbContext _context;

    public TechnicianAvailabilityRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<TechnicianAvailability?> GetByIdAsync(int id)
    {
        return await _context.TechnicianAvailabilities
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<List<TechnicianAvailability>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.TechnicianAvailabilities
            .Where(a => a.TechnicianId == technicianId)
            .ToListAsync();
    }

    public async Task AddAsync(TechnicianAvailability availability)
    {
        await _context.TechnicianAvailabilities.AddAsync(availability);
    }

    public async Task UpdateAsync(TechnicianAvailability availability)
    {
        _context.TechnicianAvailabilities.Update(availability);
    }
}