using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class CityRepository
{
    private readonly HomeFixDbContext _context;

    public CityRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<City>> GetAllAsync()
    {
        return await _context.Cities
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<List<City>> GetByGovernorateIdAsync(int governorateId)
    {
        return await _context.Cities
            .Where(c => c.GovernorateId == governorateId)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<City?> GetByIdAsync(int id)
    {
        return await _context.Cities
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task AddAsync(City city)
    {
        await _context.Cities.AddAsync(city);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(City city)
    {
        _context.Cities.Update(city);
        await _context.SaveChangesAsync();
    }
}