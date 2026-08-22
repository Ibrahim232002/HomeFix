using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianAvailabilityService : ITechnicianAvailabilityService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianAvailabilityRepository _repository;

    public TechnicianAvailabilityService(
        TechnicianAvailabilityRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<TechnicianAvailability?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<TechnicianAvailability>> GetByTechnicianIdAsync(
        int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task AddAsync(TechnicianAvailability availability)
        {
        await _repository.AddAsync(availability);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianAvailability availability)
        {
        await _repository.UpdateAsync(availability);
        await _unitOfWork.SaveChangesAsync();
    }
}
