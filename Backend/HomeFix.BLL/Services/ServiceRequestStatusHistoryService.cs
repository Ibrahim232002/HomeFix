using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestStatusHistoryService : IServiceRequestStatusHistoryService
{
    private readonly ServiceRequestStatusHistoryRepository _repository;

    public ServiceRequestStatusHistoryService(
        ServiceRequestStatusHistoryRepository repository)
    {
        _repository = repository;
    }

    public Task<List<ServiceRequestStatusHistory>> GetByRequestIdAsync(
        int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task AddAsync(ServiceRequestStatusHistory history)
        => _repository.AddAsync(history);
}