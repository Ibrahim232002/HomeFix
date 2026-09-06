using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class AddressService : IAddressService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly AddressRepository _repository;
    private readonly GovernorateRepository _governateRepository;
    private readonly CityRepository _cityRepository;

    public AddressService(
        AddressRepository repository,
        UnitOfWork unitOfWork,
        GovernorateRepository governorateRepository,
        CityRepository cityRepository)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _governateRepository = governorateRepository;
        _cityRepository = cityRepository;
    }

    public Task<Address?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Address>> GetByCustomerIdAsync(int customerId)
        => _repository.GetByCustomerIdAsync(customerId);

    public Task<bool> HasServiceRequestsAsync(int addressId)
        => _repository.HasServiceRequestsAsync(addressId);

    public async Task<string?> ValidateLocationAsync(int? governorateId, int? cityId)
    {
        if (!governorateId.HasValue && !cityId.HasValue)
            return null;

        if (!governorateId.HasValue && cityId.HasValue)
            return "Governorate is required when City is provided.";

        if (governorateId.HasValue && !cityId.HasValue)
            return "City is required when Governorate is provided.";

        var governorate = await _governateRepository.GetByIdAsync(governorateId.Value);
        if (governorate == null || !governorate.IsActive)
            return "Governorate not found or inactive.";

        var city = await _cityRepository.GetByIdAsync(cityId.Value);
        if (city == null || !city.IsActive)
            return "City not found or inactive.";

        if (city.GovernorateId != governorateId.Value)
            return "City does not belong to the selected governorate.";

        return null;
    }

    public async Task AddAsync(Address address)
    {
        await _repository.AddAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Address address)
    {
        await _repository.UpdateAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(Address address)
    {
        await _repository.DeleteAsync(address);
        await _unitOfWork.SaveChangesAsync();
    }
}
