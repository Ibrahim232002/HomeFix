using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class TechnicianWalletRepository
{
    private readonly HomeFixDbContext _context;

    public TechnicianWalletRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<TechnicianWallet?> GetByIdAsync(int id)
    {
        return await _context.TechnicianWallets
            .FirstOrDefaultAsync(w => w.Id == id);
    }

    public async Task<TechnicianWallet?> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.TechnicianWallets
            .FirstOrDefaultAsync(w => w.TechnicianId == technicianId);
    }

    public async Task AddAsync(TechnicianWallet wallet)
    {
        await _context.TechnicianWallets.AddAsync(wallet);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianWallet wallet)
    {
        _context.TechnicianWallets.Update(wallet);
        await _context.SaveChangesAsync();
    }
}