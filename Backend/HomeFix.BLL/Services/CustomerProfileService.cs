using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class CustomerProfileService : ICustomerProfileService
{
    private readonly CustomerProfileRepository _repository;

    public CustomerProfileService(CustomerProfileRepository repository)
    {
        _repository = repository;
    }

    public Task<CustomerProfile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<CustomerProfile?> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task AddAsync(CustomerProfile profile)
        => _repository.AddAsync(profile);

    public Task UpdateAsync(CustomerProfile profile)
        => _repository.UpdateAsync(profile);
}