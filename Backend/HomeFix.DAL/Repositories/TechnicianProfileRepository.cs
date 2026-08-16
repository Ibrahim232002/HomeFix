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
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task<TechnicianProfile?> GetByUserIdAsync(int userId)
    {
        return await _context.TechnicianProfiles
            .FirstOrDefaultAsync(t => t.UserId == userId);
    }

    public async Task<List<TechnicianProfile>> GetActiveTechniciansAsync()
    {
        return await _context.TechnicianProfiles
            .Where(t => t.User.IsActive)
            .ToListAsync();
    }

    public async Task AddAsync(TechnicianProfile technician)
    {
        await _context.TechnicianProfiles.AddAsync(technician);
    }

    public async Task UpdateAsync(TechnicianProfile technician)
    {
        _context.TechnicianProfiles.Update(technician);
    }
}