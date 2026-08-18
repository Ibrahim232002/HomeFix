using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceCategoryRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceCategoryRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<ServiceCategory>> GetActiveAsync()
    {
        return await _context.ServiceCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<ServiceCategory?> GetActiveByIdAsync(int id)
    {
        return await _context.ServiceCategories
            .FirstOrDefaultAsync(c => c.Id == id && c.IsActive);
    }
}
