using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceRequestService
{
    Task<ServiceRequest?> GetByIdAsync(int id);

    Task<List<ServiceRequest>> GetByCustomerIdAsync(int customerId);

    Task<List<ServiceRequest>> GetByStatusAsync(string status);

    Task CreateAsync(ServiceRequest request);

    Task UpdateAsync(ServiceRequest request);
}