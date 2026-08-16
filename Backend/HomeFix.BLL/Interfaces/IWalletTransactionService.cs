using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IWalletTransactionService
{
    Task<WalletTransaction?> GetByIdAsync(int id);
    Task<List<WalletTransaction>> GetByWalletIdAsync(int walletId);
    Task AddAsync(WalletTransaction transaction);
}