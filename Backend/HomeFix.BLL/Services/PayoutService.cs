using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PayoutService : IPayoutService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly PayoutRepository _repository;

    public PayoutService(PayoutRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Payout?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Payout>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task AddAsync(Payout payout)
        {
        await _repository.AddAsync(payout);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Payout payout)
        {
        await _repository.UpdateAsync(payout);
        await _unitOfWork.SaveChangesAsync();
    }
}
