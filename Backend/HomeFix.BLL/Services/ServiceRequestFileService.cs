using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestFileService : IServiceRequestFileService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly ServiceRequestFileRepository _repository;

    public ServiceRequestFileService(ServiceRequestFileRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<ServiceRequestFile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<ServiceRequestFile>> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public async Task AddAsync(ServiceRequestFile file)
        {
        await _repository.AddAsync(file);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(ServiceRequestFile file)
        {
        await _repository.DeleteAsync(file);
        await _unitOfWork.SaveChangesAsync();
    }
}
