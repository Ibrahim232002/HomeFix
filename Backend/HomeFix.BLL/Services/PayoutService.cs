using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using System.Data;

namespace HomeFix.BLL.Services;

public class PayoutService : IPayoutService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly PayoutRepository _repository;
    private readonly TechnicianProfileRepository _technicianRepository;
    private readonly TechnicianWalletRepository _walletRepository;
    private readonly WalletTransactionRepository _transactionRepository;

    public PayoutService(
        PayoutRepository repository,
        TechnicianProfileRepository technicianRepository,
        TechnicianWalletRepository walletRepository,
        WalletTransactionRepository transactionRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _technicianRepository = technicianRepository;
        _walletRepository = walletRepository;
        _transactionRepository = transactionRepository;
    }

    public Task<Payout?> GetByIdAsync(int id) => _repository.GetByIdAsync(id);

    public Task<List<Payout>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task<(bool Success, string? Error, Payout? Payout)> RequestAsync(
        int userId,
        decimal amount,
        string paymentMethod)
    {
        if (amount <= 0)
            return (false, "Payout amount must be greater than zero.", null);

        if (string.IsNullOrWhiteSpace(paymentMethod))
            return (false, "Payment method is required.", null);

        // Serialize wallet reads and debits so concurrent payout requests cannot
        // both observe the same balance and reserve it twice.
        await using var dbTransaction = await _unitOfWork.BeginTransactionAsync(
            IsolationLevel.Serializable);

        try
        {
            var technician = await _technicianRepository.GetByUserIdAsync(userId);
            if (technician is null)
                return (false, "Technician profile not found.", null);

            var wallet = await _walletRepository.GetByTechnicianIdAsync(technician.Id);
            if (wallet is null)
                return (false, "Technician wallet not found.", null);

            if (wallet.Balance < amount)
                return (false, "Insufficient wallet balance.", null);

            var now = DateTime.UtcNow;
            var before = wallet.Balance;
            wallet.Balance -= amount;
            wallet.UpdatedAt = now;

            var payout = new Payout
            {
                TechnicianId = technician.Id,
                Amount = amount,
                PaymentMethod = paymentMethod.Trim(),
                Status = "Pending",
                RequestedAt = now
            };

            var transaction = new WalletTransaction
            {
                WalletId = wallet.Id,
                Amount = amount,
                BalanceBefore = before,
                BalanceAfter = wallet.Balance,
                TransactionType = "Payout",
                Description = "Payout amount reserved.",
                CreatedAt = now
            };

            await _repository.AddAsync(payout);
            await _transactionRepository.AddAsync(transaction);
            await _unitOfWork.SaveChangesAsync();
            await dbTransaction.CommitAsync();

            return (true, null, payout);
        }
        catch
        {
            await dbTransaction.RollbackAsync();
            throw;
        }
    }

    public async Task AddAsync(Payout payout)
    {
        await _repository.AddAsync(payout);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Payout payout)
    {
        await _repository.UpdateAsync(payout);
        await _unitOfWork.SaveChangesAsync();
    }
}
