using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class CityService : ICityService
{
    private readonly CityRepository _repository;

    public CityService(CityRepository repository)
    {
        _repository = repository;
    }

    public Task<List<City>> GetAllAsync()
        => _repository.GetAllAsync();

    public Task<List<City>> GetByGovernorateIdAsync(int governorateId)
        => _repository.GetByGovernorateIdAsync(governorateId);

    public Task<City?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task AddAsync(City city)
        => _repository.AddAsync(city);

    public Task UpdateAsync(City city)
        => _repository.UpdateAsync(city);
}