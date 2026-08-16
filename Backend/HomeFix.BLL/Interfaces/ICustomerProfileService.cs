using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ICustomerProfileService
{
    Task<CustomerProfile?> GetByIdAsync(int id);
    Task<CustomerProfile?> GetByUserIdAsync(int userId);
    Task AddAsync(CustomerProfile profile);
    Task UpdateAsync(CustomerProfile profile);
}