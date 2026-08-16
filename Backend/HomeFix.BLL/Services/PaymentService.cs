using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PaymentService : IPaymentService
{
    private readonly PaymentRepository _repository;

    public PaymentService(PaymentRepository repository)
    {
        _repository = repository;
    }

    public Task<Payment?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Payment>> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task AddAsync(Payment payment)
        => _repository.AddAsync(payment);

    public Task UpdateAsync(Payment payment)
        => _repository.UpdateAsync(payment);
}