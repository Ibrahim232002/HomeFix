using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianProfileService : ITechnicianProfileService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianProfileRepository _repository;

    public TechnicianProfileService(TechnicianProfileRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<TechnicianProfile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianProfile?> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<List<TechnicianProfile>> GetActiveTechniciansAsync()
        => _repository.GetActiveTechniciansAsync();

    public async Task AddAsync(TechnicianProfile technician)
        {
        await _repository.AddAsync(technician);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianProfile technician)
        {
        await _repository.UpdateAsync(technician);
        await _unitOfWork.SaveChangesAsync();
    }
}
