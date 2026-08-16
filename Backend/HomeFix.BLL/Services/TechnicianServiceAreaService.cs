using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianServiceAreaService : ITechnicianServiceAreaService
{
    private readonly TechnicianServiceAreaRepository _repository;

    public TechnicianServiceAreaService(
        TechnicianServiceAreaRepository repository)
    {
        _repository = repository;
    }

    public Task<List<TechnicianServiceArea>> GetByTechnicianIdAsync(
        int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task<List<TechnicianServiceArea>> GetByCityIdAsync(int cityId)
        => _repository.GetByCityIdAsync(cityId);

    public Task AddAsync(TechnicianServiceArea area)
        => _repository.AddAsync(area);

    public Task DeleteAsync(TechnicianServiceArea area)
        => _repository.DeleteAsync(area);
}