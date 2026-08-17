using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using System.Data;

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

    public async Task<(bool Success, string? Error, decimal? Amount)> GetPayableAmountAsync(
        int serviceRequestId,
        int? authenticatedUserId = null)
    {
        var request = await _requestRepository.GetByIdAsync(serviceRequestId);
        if (request is null)
            return (false, "Service request not found.", null);

        if (authenticatedUserId.HasValue)
        {
            var customer = await _customerProfileRepository.GetByUserIdAsync(authenticatedUserId.Value);
            if (customer is null || request.CustomerId != customer.Id)
                return (false, "Service request not found.", null);
        }

        if (request.Booking is null)
            return (false, "A confirmed booking is required before payment.", null);

        var baseAmount = request.Booking.FinalPrice ?? request.Booking.AgreedPrice;
        if (!baseAmount.HasValue || baseAmount.Value <= 0)
            return (false, "The booking does not have a valid agreed price.", null);

        var promo = request.UserPromoCode;
        if (promo is not null)
        {
            // The stored UserPromoCode is authoritative. Never accept discount values from Flutter.
            var expectedCustomerUserId = request.Customer?.UserId;
            if (expectedCustomerUserId.HasValue && promo.UserId != expectedCustomerUserId.Value)
                return (false, "The promo application does not belong to this service request customer.", null);

            if (authenticatedUserId.HasValue && promo.UserId != authenticatedUserId.Value)
                return (false, "The promo application does not belong to the authenticated customer.", null);
        }

        var amount = PaymentAmountCalculator.Calculate(baseAmount.Value, promo?.DiscountAmount);
        if (amount <= 0)
            return (false, "The payable amount must be greater than zero after applying the promo discount.", null);

        return (true, null, amount);
    }

    public async Task<(bool Success, string? Error, Payment? Payment)> CreateCashForCustomerAsync(int serviceRequestId, int userId)
    {
        var payable = await GetPayableAmountAsync(serviceRequestId, userId);
        if (!payable.Success || !payable.Amount.HasValue)
            return (false, payable.Error, null);

        await using var transaction = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        var existingPayments = await _repository.GetByRequestIdAsync(serviceRequestId);

        var paid = PaymentRules.FindPaid(existingPayments);
        if (paid is not null)
        {
            await transaction.CommitAsync();
            return (true, null, paid);
        }

        var pendingCash = PaymentRules.FindPendingCash(existingPayments);
        if (pendingCash is not null)
        {
            await transaction.CommitAsync();
            return (true, null, pendingCash);
        }

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
            Amount = payable.Amount.Value,
            PaymentType = "Service",
            PaymentMethod = "Cash",
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            await _repository.AddAsync(payment);
            await _unitOfWork.SaveChangesAsync();
            await transaction.CommitAsync();
            return (true, null, payment);
        }
        catch (DbUpdateException)
        {
            await transaction.RollbackAsync();
            return (false, "An active payment already exists for this service request.", null);
        }
    }

    public async Task<(bool Success, string? Error, Payment? Payment)> CreateManualPaymentAsync(
        int serviceRequestId,
        decimal amount,
        string paymentType,
        string paymentMethod)
    {
        if (amount <= 0)
            return (false, "Amount must be greater than zero.", null);
        if (string.IsNullOrWhiteSpace(paymentType) || string.IsNullOrWhiteSpace(paymentMethod))
            return (false, "Payment type and payment method are required.", null);

        await using var transaction = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);

        var payable = await GetPayableAmountAsync(serviceRequestId);
        if (!payable.Success || !payable.Amount.HasValue)
        {
            await transaction.RollbackAsync();
            return (false, payable.Error, null);
        }

        if (amount != payable.Amount.Value)
        {
            await transaction.RollbackAsync();
            return (false, "Payment amount must match the authoritative payable amount.", null);
        }

        var existingPayments = await _repository.GetByRequestIdAsync(serviceRequestId);
        if (existingPayments.Any(PaymentRules.IsActive))
        {
            await transaction.RollbackAsync();
            return (false, "An active payment already exists for this service request.", null);
        }

        var payment = new Payment
        {
            ServiceRequestId = serviceRequestId,
            Amount = payable.Amount.Value,
            PaymentType = paymentType.Trim(),
            PaymentMethod = paymentMethod.Trim(),
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            await _repository.AddAsync(payment);
            await _unitOfWork.SaveChangesAsync();
            await transaction.CommitAsync();
            return (true, null, payment);
        }
        catch (DbUpdateException)
        {
            await transaction.RollbackAsync();
            return (false, "An active payment already exists for this service request.", null);
        }
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