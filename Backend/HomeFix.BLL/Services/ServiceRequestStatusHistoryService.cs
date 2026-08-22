using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestStatusHistoryService : IServiceRequestStatusHistoryService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly ServiceRequestStatusHistoryRepository _repository;

    public ServiceRequestStatusHistoryService(
        ServiceRequestStatusHistoryRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<ServiceRequestStatusHistory>> GetByRequestIdAsync(
        int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public async Task AddAsync(ServiceRequestStatusHistory history)
        {
        await _repository.AddAsync(history);
        await _unitOfWork.SaveChangesAsync();
    }
}
