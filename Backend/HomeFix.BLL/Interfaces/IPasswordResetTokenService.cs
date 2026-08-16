using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IPasswordResetTokenService
{
    Task<PasswordResetToken?> GetByTokenAsync(string token);
    Task<List<PasswordResetToken>> GetByUserIdAsync(int userId);
    Task AddAsync(PasswordResetToken token);
}