using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianWalletService : ITechnicianWalletService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianWalletRepository _repository;
    private readonly TechnicianProfileRepository _technicianRepository;

    public TechnicianWalletService(TechnicianWalletRepository repository,
        TechnicianProfileRepository technicianRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _technicianRepository = technicianRepository;
    }

    public Task<TechnicianWallet?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianWallet?> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task<TechnicianWallet?> GetByUserIdAsync(int userId)
    {
        var technician = await _technicianRepository.GetByUserIdAsync(userId);
        return technician is null ? null : await _repository.GetByTechnicianIdAsync(technician.Id);
    }

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
