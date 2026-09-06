using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IAddressService
{
    Task<Address?> GetByIdAsync(int id);
    Task<List<Address>> GetByCustomerIdAsync(int customerId);
    Task<bool> HasServiceRequestsAsync(int addressId);
    Task<string?> ValidateLocationAsync(int? governorateId, int? cityId);
    Task AddAsync(Address address);
    Task UpdateAsync(Address address);
    Task DeleteAsync(Address address);
}
