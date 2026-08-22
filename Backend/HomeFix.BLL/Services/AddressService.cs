using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class AddressService : IAddressService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly AddressRepository _repository;

    public AddressService(AddressRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Address?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Address>> GetByCustomerIdAsync(int customerId)
        => _repository.GetByCustomerIdAsync(customerId);

    public async Task AddAsync(Address address)
        {
        await _repository.AddAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Address address)
        {
        await _repository.UpdateAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(Address address)
        {
        await _repository.DeleteAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }
}
