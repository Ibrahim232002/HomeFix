using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class TechnicianProfileRepository
{
    private readonly HomeFixDbContext _context;

    public TechnicianProfileRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<TechnicianProfile?> GetByIdAsync(int id)
    {
        return await _context.TechnicianProfiles
            .Include(t => t.Category)
            .Include(t => t.Services)
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task<TechnicianProfile?> GetByUserIdAsync(int userId)
    {
        return await _context.TechnicianProfiles
            .Include(t => t.Category)
            .Include(t => t.Services)
            .FirstOrDefaultAsync(t => t.UserId == userId);
    }

    public async Task<List<TechnicianProfile>> GetActiveTechniciansAsync()
    {
        return await _context.TechnicianProfiles
            .Include(t => t.Category)
            .Include(t => t.Services)
            .Where(t => t.User.IsActive)
            .ToListAsync();
    }

    public Task<bool> IsEligibleForRequestAsync(int technicianId, int serviceId, int? cityId)
        => _context.TechnicianProfiles
            .Where(t => t.Id == technicianId && t.User.IsActive && t.IsVerified && t.IsAvailable)
            .AnyAsync(t => t.Services.Any(s => s.Id == serviceId) &&
                           (cityId == null || t.TechnicianServiceAreas.Any(a => a.CityId == cityId)));

    public async Task AddAsync(TechnicianProfile technician)
    {
        await _context.TechnicianProfiles.AddAsync(technician);
    }

    public async Task UpdateAsync(TechnicianProfile technician)
    {
        _context.TechnicianProfiles.Update(technician);
    }
}
