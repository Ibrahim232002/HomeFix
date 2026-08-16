using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class SupportMessageRepository
{
    private readonly HomeFixDbContext _context;

    public SupportMessageRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<List<SupportMessage>> GetByTicketIdAsync(int supportTicketId)
    {
        return await _context.SupportMessages
            .Where(m => m.SupportTicketId == supportTicketId)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(SupportMessage message)
    {
        await _context.SupportMessages.AddAsync(message);
    }
}