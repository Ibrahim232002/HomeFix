using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class WalletTransactionRepository
{
    private readonly HomeFixDbContext _context;

    public WalletTransactionRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<WalletTransaction?> GetByIdAsync(int id)
    {
        return await _context.WalletTransactions
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task<List<WalletTransaction>> GetByWalletIdAsync(int walletId)
    {
        return await _context.WalletTransactions
            .Where(t => t.WalletId == walletId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(WalletTransaction transaction)
    {
        await _context.WalletTransactions.AddAsync(transaction);
    }
}