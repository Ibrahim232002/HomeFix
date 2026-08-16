using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceRequestFileService
{
    Task<ServiceRequestFile?> GetByIdAsync(int id);
    Task<List<ServiceRequestFile>> GetByRequestIdAsync(int serviceRequestId);
    Task AddAsync(ServiceRequestFile file);
    Task DeleteAsync(ServiceRequestFile file);
}