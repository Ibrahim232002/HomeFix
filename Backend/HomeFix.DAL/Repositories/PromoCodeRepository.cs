using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class PromoCodeRepository
{
    private readonly HomeFixDbContext _context;

    public PromoCodeRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<PromoCode?> GetByIdAsync(int id)
    {
        return await _context.PromoCodes
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<PromoCode?> GetByCodeAsync(string code)
    {
        return await _context.PromoCodes
            .FirstOrDefaultAsync(p => p.Code == code);
    }

    public async Task<List<PromoCode>> GetActiveAsync()
    {
        return await _context.PromoCodes
            .Where(p => p.IsActive)
            .ToListAsync();
    }

    public Task<int> TryReserveUseAsync(int promoCodeId, DateTime now) =>
        _context.PromoCodes
            .Where(p => p.Id == promoCodeId &&
                        p.IsActive &&
                        p.StartDate <= now &&
                        p.EndDate >= now &&
                        (!p.MaxUses.HasValue || p.UsedCount < p.MaxUses.Value))
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(p => p.UsedCount, p => p.UsedCount + 1));

    public async Task AddAsync(PromoCode promoCode)
    {
        await _context.PromoCodes.AddAsync(promoCode);
    }

    public async Task UpdateAsync(PromoCode promoCode)
    {
        _context.PromoCodes.Update(promoCode);
    }
}