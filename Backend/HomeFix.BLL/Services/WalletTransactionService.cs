using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class WalletTransactionService : IWalletTransactionService
{
    private readonly WalletTransactionRepository _repository;

    public WalletTransactionService(WalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public Task<WalletTransaction?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<WalletTransaction>> GetByWalletIdAsync(int walletId)
        => _repository.GetByWalletIdAsync(walletId);

    public Task AddAsync(WalletTransaction transaction)
        => _repository.AddAsync(transaction);
}