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

    public Task<ServicePricing?> GetForServiceAsync(int serviceId, int? cityId)
        => _repository.GetForServiceAsync(serviceId, cityId);

    public Task<List<ServicePricing>> GetByServiceIdAsync(int serviceId)
        => _repository.GetByServiceIdAsync(serviceId);

    public async Task AddAsync(ServicePricing pricing)
    {
        if (pricing.ServiceId <= 0)
            throw new ArgumentException("A valid service is required.", nameof(pricing));
        if (pricing.VisitFee < 0 || pricing.MinimumPrice is < 0 || pricing.MaximumPrice is < 0)
            throw new ArgumentException("Pricing values cannot be negative.", nameof(pricing));
        if (pricing.MinimumPrice.HasValue && pricing.MaximumPrice.HasValue && pricing.MinimumPrice > pricing.MaximumPrice)
            throw new ArgumentException("Minimum price cannot exceed maximum price.", nameof(pricing));

        await _repository.AddAsync(pricing);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(ServicePricing pricing)
    {
        if (pricing.VisitFee < 0 || pricing.MinimumPrice is < 0 || pricing.MaximumPrice is < 0)
            throw new ArgumentException("Pricing values cannot be negative.", nameof(pricing));
        if (pricing.MinimumPrice.HasValue && pricing.MaximumPrice.HasValue && pricing.MinimumPrice > pricing.MaximumPrice)
            throw new ArgumentException("Minimum price cannot exceed maximum price.", nameof(pricing));

        await _repository.UpdateAsync(pricing);
        await _unitOfWork.SaveChangesAsync();
    }
}