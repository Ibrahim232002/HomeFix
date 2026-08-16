using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianServiceAreaService : ITechnicianServiceAreaService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianServiceAreaRepository _repository;

    public TechnicianServiceAreaService(
        TechnicianServiceAreaRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<TechnicianServiceArea>> GetByTechnicianIdAsync(
        int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task<List<TechnicianServiceArea>> GetByCityIdAsync(int cityId)
        => _repository.GetByCityIdAsync(cityId);

    public async Task AddAsync(TechnicianServiceArea area)
        {
        await _repository.AddAsync(area);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(TechnicianServiceArea area)
        {
        await _repository.DeleteAsync(area);
        await _unitOfWork.SaveChangesAsync();
    }
}
