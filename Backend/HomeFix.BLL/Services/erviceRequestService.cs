using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceRequestService : IServiceRequestService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly ServiceRequestRepository _serviceRequestRepository;

    public ServiceRequestService(
        ServiceRequestRepository serviceRequestRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _serviceRequestRepository = serviceRequestRepository;
    }

    public Task<ServiceRequest?> GetByIdAsync(int id)
        => _serviceRequestRepository.GetByIdAsync(id);

    public Task<List<ServiceRequest>> GetByCustomerIdAsync(int customerId)
        => _serviceRequestRepository.GetByCustomerIdAsync(customerId);

    public Task<List<ServiceRequest>> GetByStatusAsync(string status)
        => _serviceRequestRepository.GetByStatusAsync(status);

    public Task<List<ServiceRequest>> GetPendingForTechnicianAsync(int technicianId)
        => _serviceRequestRepository.GetPendingForTechnicianAsync(technicianId);

    public async Task CreateAsync(ServiceRequest request)
    {
        if (request.CustomerId <= 0)
            throw new ArgumentException("A valid customer is required.", nameof(request));
        if (request.ServiceId <= 0)
            throw new ArgumentException("A valid service is required.", nameof(request));
        if (request.AddressId <= 0)
            throw new ArgumentException("A valid address is required.", nameof(request));

        request.Status = string.IsNullOrWhiteSpace(request.Status) ? "Pending" : request.Status;
        request.CreatedAt = request.CreatedAt == default ? DateTime.UtcNow : request.CreatedAt;

        await _serviceRequestRepository.AddAsync(request);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(ServiceRequest request)
    {
        await _serviceRequestRepository.UpdateAsync(request);
        await _unitOfWork.SaveChangesAsync();
    }
}
