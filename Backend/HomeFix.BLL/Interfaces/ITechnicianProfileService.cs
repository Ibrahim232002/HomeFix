using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianProfileService
{
    Task<TechnicianProfile?> GetByIdAsync(int id);
    Task<TechnicianProfile?> GetByUserIdAsync(int userId);
    Task<List<TechnicianProfile>> GetActiveTechniciansAsync();
    Task AddAsync(TechnicianProfile technician);
    Task UpdateAsync(TechnicianProfile technician);
}