using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServicePricingService : IServicePricingService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly ServicePricingRepository _repository;

    public ServicePricingService(ServicePricingRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<ServicePricing?> GetAsync(int serviceId, int cityId)
        => _repository.GetAsync(serviceId, cityId);

    public Task<List<ServicePricing>> GetByServiceIdAsync(int serviceId)
        => _repository.GetByServiceIdAsync(serviceId);

    public async Task AddAsync(ServicePricing pricing)
        {
        await _repository.AddAsync(pricing);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(ServicePricing pricing)
        {
        await _repository.UpdateAsync(pricing);
        await _unitOfWork.SaveChangesAsync();
    }
}
