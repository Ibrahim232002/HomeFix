using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianWalletService : ITechnicianWalletService
{
    private readonly TechnicianWalletRepository _repository;

    public TechnicianWalletService(TechnicianWalletRepository repository)
    {
        _repository = repository;
    }

    public Task<TechnicianWallet?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianWallet?> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task AddAsync(TechnicianWallet wallet)
        => _repository.AddAsync(wallet);

    public Task UpdateAsync(TechnicianWallet wallet)
        => _repository.UpdateAsync(wallet);
}