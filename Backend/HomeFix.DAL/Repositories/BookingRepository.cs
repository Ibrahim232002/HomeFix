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

    public async Task<Booking?> GetByIdAsync(int id)
    {
        return await _context.Bookings
            .Include(b => b.ServiceRequest)
            .Include(b => b.Technician)
            .FirstOrDefaultAsync(b => b.Id == id);
    }

    public async Task<Booking?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _context.Bookings
            .Include(b => b.Technician)
            .FirstOrDefaultAsync(b => b.ServiceRequestId == serviceRequestId);
    }

    public async Task<List<Booking>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.Bookings
            .Include(b => b.ServiceRequest)
            .Where(b => b.TechnicianId == technicianId)
            .OrderByDescending(b => b.Id)
            .ToListAsync();
    }

    public async Task AddAsync(Booking booking)
    {
        await _context.Bookings.AddAsync(booking);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Booking booking)
    {
        _context.Bookings.Update(booking);
        await _context.SaveChangesAsync();
    }
}