using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class GovernorateService : IGovernorateService
{
    private readonly GovernorateRepository _repository;

    public GovernorateService(GovernorateRepository repository)
    {
        _repository = repository;
    }

    public Task<List<Governorate>> GetAllAsync()
        => _repository.GetAllAsync();

    public Task<Governorate?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task AddAsync(Governorate governorate)
        => _repository.AddAsync(governorate);

    public Task UpdateAsync(Governorate governorate)
        => _repository.UpdateAsync(governorate);
}