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
    private readonly ServiceCategoryRepository _serviceCategoryRepository;
    private readonly ServiceRepository _serviceRepository;

    public TechnicianProfileService(
        TechnicianProfileRepository repository,
        UnitOfWork unitOfWork,
        GovernorateRepository governorateRepository,
        CityRepository cityRepository,
        ServiceCategoryRepository serviceCategoryRepository,
        ServiceRepository serviceRepository)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _governorateRepository = governorateRepository;
        _cityRepository = cityRepository;
        _serviceCategoryRepository = serviceCategoryRepository;
        _serviceRepository = serviceRepository;
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

    public async Task<string?> ApplySpecializationAsync(
        TechnicianProfile technician,
        int? categoryId,
        IReadOnlyCollection<int>? serviceIds)
    {
        var effectiveCategoryId = categoryId ?? technician.CategoryId;

        if (effectiveCategoryId <= 0)
            return "Technician category is required.";

        var category = await _serviceCategoryRepository.GetActiveByIdAsync(effectiveCategoryId);
        if (category is null)
            return "The selected service category is invalid or inactive.";

        var categoryChanged = technician.CategoryId != effectiveCategoryId;
        if (categoryChanged)
        {
            technician.CategoryId = effectiveCategoryId;

            // A category change invalidates the old concrete services.
            technician.Services.Clear();
        }

        if (serviceIds is null)
            return null;

        var requestedIds = serviceIds.Distinct().ToList();
        var services = await _serviceRepository.GetActiveByIdsAsync(requestedIds);

        if (services.Count != requestedIds.Count)
            return "One or more selected services are invalid or inactive.";

        var invalidService = services.FirstOrDefault(s => s.CategoryId != effectiveCategoryId);
        if (invalidService is not null)
        {
            return "A selected service does not belong to the technician's service category.";
        }

        technician.Services.Clear();
        foreach (var service in services)
            technician.Services.Add(service);

        return null;
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
