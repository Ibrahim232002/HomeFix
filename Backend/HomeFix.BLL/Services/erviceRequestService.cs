using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestService : IServiceRequestService
{
    private readonly ServiceRequestRepository _serviceRequestRepository;

    public ServiceRequestService(
        ServiceRequestRepository serviceRequestRepository)
    {
        _serviceRequestRepository = serviceRequestRepository;
    }

    public async Task<ServiceRequest?> GetByIdAsync(int id)
    {
        return await _serviceRequestRepository.GetByIdAsync(id);
    }

    public async Task<List<ServiceRequest>> GetByCustomerIdAsync(
        int customerId)
    {
        return await _serviceRequestRepository
            .GetByCustomerIdAsync(customerId);
    }

    public async Task<List<ServiceRequest>> GetByStatusAsync(
        string status)
    {
        return await _serviceRequestRepository
            .GetByStatusAsync(status);
    }

    public async Task CreateAsync(ServiceRequest request)
    {
        await _serviceRequestRepository.AddAsync(request);
    }

    public async Task UpdateAsync(ServiceRequest request)
    {
        await _serviceRequestRepository.UpdateAsync(request);
    }
}