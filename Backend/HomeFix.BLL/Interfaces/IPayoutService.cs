using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IPayoutService
{
    Task<Payout?> GetByIdAsync(int id);
    Task<List<Payout>> GetByTechnicianIdAsync(int technicianId);
    Task AddAsync(Payout payout);
    Task UpdateAsync(Payout payout);
}