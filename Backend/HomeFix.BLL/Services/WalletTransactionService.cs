using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class WalletTransactionService : IWalletTransactionService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly WalletTransactionRepository _repository;

    public WalletTransactionService(WalletTransactionRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<WalletTransaction?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<WalletTransaction>> GetByWalletIdAsync(int walletId)
        => _repository.GetByWalletIdAsync(walletId);

    public async Task AddAsync(WalletTransaction transaction)
        {
        await _repository.AddAsync(transaction);
        await _unitOfWork.SaveChangesAsync();
    }
}
