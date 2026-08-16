using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PaymentService : IPaymentService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly PaymentRepository _repository;
    private readonly ServiceRequestRepository _requestRepository;
    private readonly CustomerProfileRepository _customerProfileRepository;

    public PaymentService(
        PaymentRepository repository,
        ServiceRequestRepository requestRepository,
        CustomerProfileRepository customerProfileRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _requestRepository = requestRepository;
        _customerProfileRepository = customerProfileRepository;
    }

    public Task<Payment?> GetByIdAsync(int id) => _repository.GetByIdAsync(id);

    public Task<List<Payment>> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public async Task<(bool Success, string? Error, Payment? Payment)> CreateCashForCustomerAsync(int serviceRequestId, int userId)
    {
        var customer = await _customerProfileRepository.GetByUserIdAsync(userId);
        if (customer is null)
            return (false, "Customer profile not found.", null);

        var request = await _requestRepository.GetByIdAsync(serviceRequestId);
        if (request is null || request.CustomerId != customer.Id)
            return (false, "Service request not found.", null);

        if (request.Booking is null)
            return (false, "A confirmed booking is required before payment.", null);

        var amount = request.Booking.FinalPrice ?? request.Booking.AgreedPrice;
        if (!amount.HasValue || amount.Value <= 0)
            return (false, "The booking does not have a valid agreed price.", null);

        await using var transaction = await _unitOfWork.BeginTransactionAsync();

        var existingPayments = await _repository.GetByRequestIdAsync(serviceRequestId);

        // A successful payment means the service request is already paid.
        // Never create a second payment, even if the existing payment used a different method.
        var paid = existingPayments.FirstOrDefault(p =>
            p.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase));

        if (paid is not null)
        {
            await transaction.CommitAsync();
            return (true, null, paid);
        }

        // Reuse an existing pending cash payment rather than creating another one.
        var pendingCash = existingPayments.FirstOrDefault(p =>
            p.PaymentMethod.Equals("Cash", StringComparison.OrdinalIgnoreCase) &&
            p.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase));

        if (pendingCash is not null)
        {
            await transaction.CommitAsync();
            return (true, null, pendingCash);
        }

        // Do not allow two payment flows to remain open for the same request.
        var pendingPayment = existingPayments.FirstOrDefault(p =>
            p.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase));

        if (pendingPayment is not null)
        {
            await transaction.CommitAsync();
            return (false, "A payment is already pending for this service request.", null);
        }

        var payment = new Payment
        {
            ServiceRequestId = serviceRequestId,
            Amount = amount.Value,
            PaymentType = "Service",
            PaymentMethod = "Cash",
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        await _repository.AddAsync(payment);
        await _unitOfWork.SaveChangesAsync();
        await transaction.CommitAsync();

        return (true, null, payment);
    }

    public async Task AddAsync(Payment payment)
    {
        await _repository.AddAsync(payment);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Payment payment)
    {
        await _repository.UpdateAsync(payment);
        await _unitOfWork.SaveChangesAsync();
    }
}
