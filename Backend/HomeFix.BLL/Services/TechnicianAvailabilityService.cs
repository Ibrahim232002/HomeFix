using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianAvailabilityService : ITechnicianAvailabilityService
{
    private readonly TechnicianAvailabilityRepository _repository;

    public TechnicianAvailabilityService(
        TechnicianAvailabilityRepository repository)
    {
        _repository = repository;
    }

    public Task<TechnicianAvailability?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<TechnicianAvailability>> GetByTechnicianIdAsync(
        int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task AddAsync(TechnicianAvailability availability)
        => _repository.AddAsync(availability);

    public Task UpdateAsync(TechnicianAvailability availability)
        => _repository.UpdateAsync(availability);
}