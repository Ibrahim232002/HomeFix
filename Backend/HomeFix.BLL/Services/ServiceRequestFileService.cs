using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestFileService : IServiceRequestFileService
{
    private readonly ServiceRequestFileRepository _repository;

    public ServiceRequestFileService(ServiceRequestFileRepository repository)
    {
        _repository = repository;
    }

    public Task<ServiceRequestFile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<ServiceRequestFile>> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task AddAsync(ServiceRequestFile file)
        => _repository.AddAsync(file);

    public Task DeleteAsync(ServiceRequestFile file)
        => _repository.DeleteAsync(file);
}