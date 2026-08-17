using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IPaymentService
{
    Task<Payment?> GetByIdAsync(int id);
    Task<List<Payment>> GetByRequestIdAsync(int serviceRequestId);
    Task<(bool Success, string? Error, decimal? Amount)> GetPayableAmountAsync(int serviceRequestId, int? authenticatedUserId = null);
    Task<(bool Success, string? Error, Payment? Payment)> CreateCashForCustomerAsync(int serviceRequestId, int userId);
    Task<(bool Success, string? Error, Payment? Payment)> CreateManualPaymentAsync(int serviceRequestId, decimal amount, string paymentType, string paymentMethod);
    Task AddAsync(Payment payment);
    Task UpdateAsync(Payment payment);
}
