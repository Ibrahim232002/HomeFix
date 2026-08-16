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

    public async Task AddAsync(PromoCode promoCode)
    {
        await _context.PromoCodes.AddAsync(promoCode);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(PromoCode promoCode)
    {
        _context.PromoCodes.Update(promoCode);
        await _context.SaveChangesAsync();
    }
}