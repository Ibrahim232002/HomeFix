using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class CustomerProfileService : ICustomerProfileService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly CustomerProfileRepository _repository;

    public CustomerProfileService(CustomerProfileRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<CustomerProfile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<CustomerProfile?> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public async Task AddAsync(CustomerProfile profile)
        {
        await _repository.AddAsync(profile);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(CustomerProfile profile)
        {
        await _repository.UpdateAsync(profile);
        await _unitOfWork.SaveChangesAsync();
    }
}
