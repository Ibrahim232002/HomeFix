using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ServiceRequestFileRepository
{
    private readonly HomeFixDbContext _context;

    public ServiceRequestFileRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<ServiceRequestFile?> GetByIdAsync(int id)
    {
        return await _context.ServiceRequestFiles
            .FirstOrDefaultAsync(f => f.Id == id);
    }

    public async Task<List<ServiceRequestFile>> GetByRequestIdAsync(
        int serviceRequestId)
    {
        return await _context.ServiceRequestFiles
            .Where(f => f.ServiceRequestId == serviceRequestId)
            .OrderBy(f => f.UploadedAt)
            .ToListAsync();
    }

    public async Task AddAsync(ServiceRequestFile file)
    {
        await _context.ServiceRequestFiles.AddAsync(file);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(ServiceRequestFile file)
    {
        _context.ServiceRequestFiles.Remove(file);
        await _context.SaveChangesAsync();
    }
}