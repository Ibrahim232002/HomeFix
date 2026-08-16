using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class AddressService : IAddressService
{
    private readonly AddressRepository _repository;

    public AddressService(AddressRepository repository)
    {
        _repository = repository;
    }

    public Task<Address?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Address>> GetByCustomerIdAsync(int customerId)
        => _repository.GetByCustomerIdAsync(customerId);

    public Task AddAsync(Address address)
        => _repository.AddAsync(address);

    public Task UpdateAsync(Address address)
        => _repository.UpdateAsync(address);

    public Task DeleteAsync(Address address)
        => _repository.DeleteAsync(address);
}