using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianProfileService : ITechnicianProfileService
{
    private readonly TechnicianProfileRepository _repository;

    public TechnicianProfileService(TechnicianProfileRepository repository)
    {
        _repository = repository;
    }

    public Task<TechnicianProfile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianProfile?> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<List<TechnicianProfile>> GetActiveTechniciansAsync()
        => _repository.GetActiveTechniciansAsync();

    public Task AddAsync(TechnicianProfile technician)
        => _repository.AddAsync(technician);

    public Task UpdateAsync(TechnicianProfile technician)
        => _repository.UpdateAsync(technician);
}