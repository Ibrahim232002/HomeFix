using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianServiceAreaService
{
    Task<List<TechnicianServiceArea>> GetByTechnicianIdAsync(int technicianId);
    Task<List<TechnicianServiceArea>> GetByCityIdAsync(int cityId);
    Task AddAsync(TechnicianServiceArea area);
    Task DeleteAsync(TechnicianServiceArea area);
}