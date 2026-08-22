using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceQuoteRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceQuoteRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public Task<ServiceQuote?> GetByIdAsync(int id)
    {
        return _context.Set<ServiceQuote>()
            .Include(q => q.Inspection)
                .ThenInclude(i => i.ServiceRequest)
                    .ThenInclude(r => r.Customer)
                        .ThenInclude(c => c.User)
            .Include(q => q.Inspection)
                .ThenInclude(i => i.Technician)
            .FirstOrDefaultAsync(q => q.Id == id);
    }

    public Task<List<ServiceQuote>> GetByInspectionIdAsync(int inspectionId)
    {
        return _context.Set<ServiceQuote>()
            .Where(q => q.InspectionId == inspectionId)
            .OrderBy(q => q.Revision)
            .ToListAsync();
    }

    public Task AddAsync(ServiceQuote quote)
        => _context.Set<ServiceQuote>().AddAsync(quote).AsTask();

    public void Update(ServiceQuote quote)
        => _context.Set<ServiceQuote>().Update(quote);
}
