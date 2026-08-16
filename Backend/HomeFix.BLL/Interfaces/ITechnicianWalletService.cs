using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianWalletService
{
    Task<TechnicianWallet?> GetByIdAsync(int id);
    Task<TechnicianWallet?> GetByTechnicianIdAsync(int technicianId);
    Task<TechnicianWallet?> GetByUserIdAsync(int userId);
    Task AddAsync(TechnicianWallet wallet);
    Task UpdateAsync(TechnicianWallet wallet);
}