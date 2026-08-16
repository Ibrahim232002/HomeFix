using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceRequestStatusHistoryRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceRequestStatusHistoryRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<ServiceRequestStatusHistory>> GetByRequestIdAsync(
        int serviceRequestId)
    {
        return await _context.ServiceRequestStatusHistories
            .Include(h => h.ChangedByUser)
            .Where(h => h.ServiceRequestId == serviceRequestId)
            .OrderBy(h => h.ChangedAt)
            .ToListAsync();
    }

    public async Task AddAsync(ServiceRequestStatusHistory history)
    {
        await _context.ServiceRequestStatusHistories.AddAsync(history);
    }
}