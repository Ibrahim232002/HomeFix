using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class SupportTicketRepository
{
    private readonly HomeFixDbContext _context;

    public SupportTicketRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<SupportTicket?> GetByIdAsync(int id)
    {
        return await _context.SupportTickets
            .Include(t => t.User)
            .Include(t => t.ServiceRequest)
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task<List<SupportTicket>> GetByUserIdAsync(int userId)
    {
        return await _context.SupportTickets
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<SupportTicket>> GetByStatusAsync(string status)
    {
        return await _context.SupportTickets
            .Where(t => t.Status == status)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(SupportTicket ticket)
    {
        await _context.SupportTickets.AddAsync(ticket);
    }

    public async Task UpdateAsync(SupportTicket ticket)
    {
        _context.SupportTickets.Update(ticket);
    }
}