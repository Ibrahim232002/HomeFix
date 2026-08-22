using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class CityService : ICityService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly CityRepository _repository;

    public CityService(CityRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<City>> GetAllAsync()
        => _repository.GetAllAsync();

    public Task<List<City>> GetByGovernorateIdAsync(int governorateId)
        => _repository.GetByGovernorateIdAsync(governorateId);

    public Task<City?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public async Task AddAsync(City city)
        {
        await _repository.AddAsync(city);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(City city)
        {
        await _repository.UpdateAsync(city);
        await _unitOfWork.SaveChangesAsync();
    }
}
