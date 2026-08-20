using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<Service>> GetAllAsync()
    {
        return await _context.Services
            .Where(s => s.IsActive)
            .OrderBy(s => s.Name)
            .ToListAsync();
    }

    public async Task<Service?> GetByIdAsync(int id)
    {
        return await _context.Services
            .FirstOrDefaultAsync(s => s.Id == id);
    }

    public async Task<List<Service>> GetActiveByCategoryAsync(int categoryId)
    {
        return await _context.Services
            .Where(s => s.IsActive && s.CategoryId == categoryId)
            .OrderBy(s => s.Name)
            .ToListAsync();
    }

    public async Task<List<Service>> GetActiveByIdsAsync(IEnumerable<int> ids)
    {
        var distinctIds = ids.Distinct().ToList();
        if (distinctIds.Count == 0)
            return new List<Service>();

        return await _context.Services
            .Where(s => s.IsActive && distinctIds.Contains(s.Id))
            .ToListAsync();
    }

    public async Task AddAsync(Service service)
    {
        await _context.Services.AddAsync(service);
    }

    public async Task UpdateAsync(Service service)
    {
        _context.Services.Update(service);
    }
}
