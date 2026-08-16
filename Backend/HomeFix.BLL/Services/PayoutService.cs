using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PayoutService : IPayoutService
{
    private readonly PayoutRepository _repository;

    public PayoutService(PayoutRepository repository)
    {
        _repository = repository;
    }

    public Task<Payout?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Payout>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task AddAsync(Payout payout)
        => _repository.AddAsync(payout);

    public Task UpdateAsync(Payout payout)
        => _repository.UpdateAsync(payout);
}