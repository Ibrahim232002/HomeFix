using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ICityService
{
    Task<List<City>> GetAllAsync();
    Task<List<City>> GetByGovernorateIdAsync(int governorateId);
    Task<City?> GetByIdAsync(int id);
    Task AddAsync(City city);
    Task UpdateAsync(City city);
}