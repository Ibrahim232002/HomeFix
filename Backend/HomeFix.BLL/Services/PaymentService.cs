using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PaymentService : IPaymentService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly PaymentRepository _repository;

    public PaymentService(PaymentRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Payment?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Payment>> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

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
