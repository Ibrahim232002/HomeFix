using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianProfileService : ITechnicianProfileService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly TechnicianProfileRepository _repository;
    private readonly GovernorateRepository _governorateRepository;
    private readonly CityRepository _cityRepository;

    public TechnicianProfileService(
        TechnicianProfileRepository repository,
        UnitOfWork unitOfWork,
        GovernorateRepository governorateRepository,
        CityRepository cityRepository)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _governorateRepository = governorateRepository;
        _cityRepository = cityRepository;
    }

    public Task<TechnicianProfile?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<TechnicianProfile?> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<List<TechnicianProfile>> GetActiveTechniciansAsync()
        => _repository.GetActiveTechniciansAsync();

    public async Task AddAsync(TechnicianProfile technician)
    {
        await _repository.AddAsync(technician);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianProfile technician)
    {
        await _repository.UpdateAsync(technician);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<string?> ValidateCurrentLocationAsync(int? governorateId, int? cityId)
    {
        if (governorateId is null && cityId is null)
            return null;

        if (governorateId is null && cityId is not null)
            return "CurrentCityId cannot be set without CurrentGovernorateId.";

        var governorate = await _governorateRepository.GetByIdAsync(governorateId!.Value);
        if (governorate is null || !governorate.IsActive)
            return "The selected governorate is invalid.";

        if (cityId is null)
            return null;

        var city = await _cityRepository.GetByIdAsync(cityId.Value);
        if (city is null || !city.IsActive)
            return "The selected city is invalid.";

        if (city.GovernorateId != governorateId.Value)
            return "The selected city does not belong to the selected governorate.";

        return null;
    }
}
