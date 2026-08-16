using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class PayoutRepository
{
    private readonly HomeFixDbContext _context;

    public PayoutRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<Payout?> GetByIdAsync(int id)
    {
        return await _context.Payouts
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<List<Payout>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.Payouts
            .Where(p => p.TechnicianId == technicianId)
            .OrderByDescending(p => p.RequestedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Payout payout)
    {
        await _context.Payouts.AddAsync(payout);
    }

    public async Task UpdateAsync(Payout payout)
    {
        _context.Payouts.Update(payout);
    }
}