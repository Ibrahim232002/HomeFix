using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianAvailabilityService
{
    Task<TechnicianAvailability?> GetByIdAsync(int id);
    Task<List<TechnicianAvailability>> GetByTechnicianIdAsync(int technicianId);
    Task AddAsync(TechnicianAvailability availability);
    Task UpdateAsync(TechnicianAvailability availability);
}