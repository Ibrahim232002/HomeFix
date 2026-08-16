using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServicePricingService : IServicePricingService
{
    private readonly ServicePricingRepository _repository;

    public ServicePricingService(ServicePricingRepository repository)
    {
        _repository = repository;
    }

    public Task<ServicePricing?> GetAsync(int serviceId, int cityId)
        => _repository.GetAsync(serviceId, cityId);

    public Task<List<ServicePricing>> GetByServiceIdAsync(int serviceId)
        => _repository.GetByServiceIdAsync(serviceId);

    public Task AddAsync(ServicePricing pricing)
        => _repository.AddAsync(pricing);

    public Task UpdateAsync(ServicePricing pricing)
        => _repository.UpdateAsync(pricing);
}