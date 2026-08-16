using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IPayoutService
{
    Task<Payout?> GetByIdAsync(int id);
    Task<List<Payout>> GetByTechnicianIdAsync(int technicianId);
    Task<(bool Success, string? Error, Payout? Payout)> RequestAsync(int userId, decimal amount, string paymentMethod);
    Task AddAsync(Payout payout);
    Task UpdateAsync(Payout payout);
}
