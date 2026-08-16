using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IGovernorateService
{
    Task<List<Governorate>> GetAllAsync();
    Task<Governorate?> GetByIdAsync(int id);
    Task AddAsync(Governorate governorate);
    Task UpdateAsync(Governorate governorate);
}