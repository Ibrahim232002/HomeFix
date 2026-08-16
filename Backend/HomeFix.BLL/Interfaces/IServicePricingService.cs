using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServicePricingService
{
    Task<ServicePricing?> GetAsync(int serviceId, int cityId);
    Task<List<ServicePricing>> GetByServiceIdAsync(int serviceId);
    Task AddAsync(ServicePricing pricing);
    Task UpdateAsync(ServicePricing pricing);
}