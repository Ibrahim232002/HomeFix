using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class InspectionRepository
{
    private readonly HomeFixDbContext _context;

    public InspectionRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public Task<Inspection?> GetByIdAsync(int id)
    {
        return _context.Set<Inspection>()
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Customer)
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Booking)
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Service)
            .Include(i => i.Technician)
            .FirstOrDefaultAsync(i => i.Id == id);
    }

    public Task<Inspection?> GetByRequestIdAsync(int serviceRequestId)
    {
        return _context.Set<Inspection>()
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Customer)
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Booking)
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Service)
            .Include(i => i.Technician)
            .FirstOrDefaultAsync(i => i.ServiceRequestId == serviceRequestId);
    }

    public Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId)
    {
        return _context.Set<Inspection>()
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Service)
            .Include(i => i.ServiceRequest)
                .ThenInclude(r => r.Address)
            .Where(i => i.TechnicianId == technicianId)
            .OrderByDescending(i => i.CreatedAt)
            .ToListAsync();
    }

    public Task AddAsync(Inspection inspection)
        => _context.Set<Inspection>().AddAsync(inspection).AsTask();

    public void Update(Inspection inspection)
        => _context.Set<Inspection>().Update(inspection);
}
