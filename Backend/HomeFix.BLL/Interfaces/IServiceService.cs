using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceService
{
    Task<List<Service>> GetAllServicesAsync();

    Task<Service?> GetServiceByIdAsync(int id);
}