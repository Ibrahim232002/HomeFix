using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class GovernorateRepository
{
    private readonly HomeFixDbContext _context;

    public GovernorateRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<Governorate>> GetAllAsync()
    {
        return await _context.Governorates
            .OrderBy(g => g.Name)
            .ToListAsync();
    }

    public async Task<Governorate?> GetByIdAsync(int id)
    {
        return await _context.Governorates
            .FirstOrDefaultAsync(g => g.Id == id);
    }

    public async Task AddAsync(Governorate governorate)
    {
        await _context.Governorates.AddAsync(governorate);
    }

    public async Task UpdateAsync(Governorate governorate)
    {
        _context.Governorates.Update(governorate);
    }
}