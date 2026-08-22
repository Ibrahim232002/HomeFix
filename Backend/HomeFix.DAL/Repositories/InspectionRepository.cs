using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class InspectionRepository
{
    private readonly HomeFixDbContext _context;

    public InspectionRepository(HomeFixDbContext context) => _context = context;

    public Task<Inspection?> GetByIdAsync(int id) =>
        _context.Set<Inspection>()
            .Include(x => x.ServiceRequest).ThenInclude(r => r.Customer)
            .Include(x => x.ServiceRequest).ThenInclude(r => r.Address)
            .Include(x => x.Technician).ThenInclude(t => t.User)
            .Include(x => x.ServiceQuotes)
            .FirstOrDefaultAsync(x => x.Id == id);

    public Task<Inspection?> GetByRequestIdAsync(int requestId) =>
        _context.Set<Inspection>()
            .Include(x => x.ServiceRequest).ThenInclude(r => r.Customer)
            .Include(x => x.ServiceRequest).ThenInclude(r => r.Address)
            .Include(x => x.Technician).ThenInclude(t => t.User)
            .Include(x => x.ServiceQuotes)
            .FirstOrDefaultAsync(x => x.ServiceRequestId == requestId);

    public Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId) =>
        _context.Set<Inspection>()
            .Include(x => x.ServiceRequest).ThenInclude(r => r.Service)
            .Where(x => x.TechnicianId == technicianId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

    public Task AddAsync(Inspection inspection) => _context.Set<Inspection>().AddAsync(inspection).AsTask();

    public void Update(Inspection inspection) => _context.Set<Inspection>().Update(inspection);
}
