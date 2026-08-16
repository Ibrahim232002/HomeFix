using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using HomeFix.BLL.Interfaces;

namespace HomeFix.BLL.Services;

public class ServiceService : IServiceService
{
    private readonly ServiceRepository _serviceRepository;

    public ServiceService(ServiceRepository serviceRepository)
    {
        _serviceRepository = serviceRepository;
    }

    public async Task<List<Service>> GetAllServicesAsync()
    {
        return await _serviceRepository.GetAllAsync();
    }

    public async Task<Service?> GetServiceByIdAsync(int id)
    {
        return await _serviceRepository.GetByIdAsync(id);
    }
}