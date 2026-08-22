using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class GovernorateService : IGovernorateService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly GovernorateRepository _repository;

    public GovernorateService(GovernorateRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<Governorate>> GetAllAsync()
        => _repository.GetAllAsync();

    public Task<Governorate?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public async Task AddAsync(Governorate governorate)
        {
        await _repository.AddAsync(governorate);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Governorate governorate)
        {
        await _repository.UpdateAsync(governorate);
        await _unitOfWork.SaveChangesAsync();
    }
}
