using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ReviewRepository
{
    private readonly HomeFixDbContext _context;

    public ReviewRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<Review?> GetByIdAsync(int id)
    {
        return await _context.Reviews
            .Include(r => r.Customer)
            .Include(r => r.Technician)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<Review?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _context.Reviews
            .FirstOrDefaultAsync(r => r.ServiceRequestId == serviceRequestId);
    }

    public async Task<List<Review>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.Reviews
            .Where(r => r.TechnicianId == technicianId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Review review)
    {
        await _context.Reviews.AddAsync(review);
    }
}