using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianProfileService
{
    Task<TechnicianProfile?> GetByIdAsync(int id);
    Task<TechnicianProfile?> GetByUserIdAsync(int userId);
    Task<List<TechnicianProfile>> GetActiveTechniciansAsync();
    Task AddAsync(TechnicianProfile technician);
    Task UpdateAsync(TechnicianProfile technician);
    Task<string?> ValidateCurrentLocationAsync(int? governorateId, int? cityId);
    Task<string?> ApplySpecializationAsync(TechnicianProfile technician, int? categoryId, IReadOnlyCollection<int>? serviceIds);
}
