using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianWalletService : ITechnicianWalletService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianWalletRepository _repository;

    public TechnicianWalletService(TechnicianWalletRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<TechnicianWallet?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianWallet?> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task AddAsync(TechnicianWallet wallet)
        {
        await _repository.AddAsync(wallet);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianWallet wallet)
        {
        await _repository.UpdateAsync(wallet);
        await _unitOfWork.SaveChangesAsync();
    }
}
