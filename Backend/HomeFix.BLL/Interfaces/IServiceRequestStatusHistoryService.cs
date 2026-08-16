using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceRequestStatusHistoryService
{
    Task<List<ServiceRequestStatusHistory>> GetByRequestIdAsync(int serviceRequestId);
    Task AddAsync(ServiceRequestStatusHistory history);
}