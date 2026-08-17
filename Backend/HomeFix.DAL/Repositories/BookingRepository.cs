using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class BookingRepository
{
    private readonly HomeFixDbContext _context;

    public BookingRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    private IQueryable<Booking> WithPresentationGraph(IQueryable<Booking> query)
        => query
            .Include(b => b.Technician)
            .Include(b => b.ServiceRequest)
                .ThenInclude(r => r.Service)
            .Include(b => b.ServiceRequest)
                .ThenInclude(r => r.Address)
                    .ThenInclude(a => a.City)
            .Include(b => b.ServiceRequest)
                .ThenInclude(r => r.Address)
                    .ThenInclude(a => a.Governorate)
            .Include(b => b.ServiceRequest)
                .ThenInclude(r => r.Customer)
                    .ThenInclude(c => c.User);

    public async Task<Booking?> GetByIdAsync(int id)
    {
        return await WithPresentationGraph(_context.Bookings)
            .FirstOrDefaultAsync(b => b.Id == id);
    }

    public async Task<Booking?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await WithPresentationGraph(_context.Bookings)
            .FirstOrDefaultAsync(b => b.ServiceRequestId == serviceRequestId);
    }

    public async Task<List<Booking>> GetByTechnicianIdAsync(int technicianId)
    {
        return await WithPresentationGraph(_context.Bookings)
            .Where(b => b.TechnicianId == technicianId)
            .OrderByDescending(b => b.Id)
            .ToListAsync();
    }

    public async Task AddAsync(Booking booking)
    {
        await _context.Bookings.AddAsync(booking);
    }

    public async Task UpdateAsync(Booking booking)
    {
        _context.Bookings.Update(booking);
    }
}