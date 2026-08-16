using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ConversationRepository
{
    private readonly HomeFixDbContext _context;

    public ConversationRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<Conversation?> GetByIdAsync(int id)
    {
        return await _context.Conversations
            .Include(c => c.Customer)
            .Include(c => c.Technician)
            .Include(c => c.ServiceRequest)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<Conversation?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _context.Conversations
            .FirstOrDefaultAsync(c => c.ServiceRequestId == serviceRequestId);
    }

    public async Task<List<Conversation>> GetByCustomerIdAsync(int customerId)
    {
        return await _context.Conversations
            .Where(c => c.CustomerId == customerId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Conversation>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.Conversations
            .Where(c => c.TechnicianId == technicianId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Conversation conversation)
    {
        await _context.Conversations.AddAsync(conversation);
        await _context.SaveChangesAsync();
    }
}