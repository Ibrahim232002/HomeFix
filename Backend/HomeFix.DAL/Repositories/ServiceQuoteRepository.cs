using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceQuoteRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceQuoteRepository(HomeFixDbContext context) => _context = context;

    public Task<ServiceQuote?> GetByIdAsync(int id) =>
        _context.Set<ServiceQuote>()
            .Include(x => x.Inspection).ThenInclude(i => i.ServiceRequest).ThenInclude(r => r.Customer)
            .Include(x => x.Inspection).ThenInclude(i => i.ServiceRequest).ThenInclude(r => r.Booking)
            .Include(x => x.Inspection).ThenInclude(i => i.Technician).ThenInclude(t => t.User)
            .FirstOrDefaultAsync(x => x.Id == id);

    public Task<List<ServiceQuote>> GetByInspectionIdAsync(int inspectionId) =>
        _context.Set<ServiceQuote>()
            .Where(x => x.InspectionId == inspectionId)
            .OrderByDescending(x => x.Revision)
            .ThenByDescending(x => x.CreatedAt)
            .ToListAsync();

    public Task<ServiceQuote?> GetPendingAsync(int inspectionId) =>
        _context.Set<ServiceQuote>()
            .Where(x => x.InspectionId == inspectionId && x.Status == "PendingCustomer")
            .OrderByDescending(x => x.Revision)
            .FirstOrDefaultAsync();

    public async Task<int> GetNextRevisionAsync(int inspectionId)
    {
        var max = await _context.Set<ServiceQuote>()
            .Where(x => x.InspectionId == inspectionId)
            .Select(x => (int?)x.Revision)
            .MaxAsync() ?? 0;
        return max + 1;
    }

    public Task AddAsync(ServiceQuote quote) => _context.Set<ServiceQuote>().AddAsync(quote).AsTask();

    public void Update(ServiceQuote quote) => _context.Set<ServiceQuote>().Update(quote);
}
