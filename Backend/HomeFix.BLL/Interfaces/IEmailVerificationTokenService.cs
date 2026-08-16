using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IEmailVerificationTokenService
{
    Task<EmailVerificationToken?> GetByTokenAsync(string token);
    Task<List<EmailVerificationToken>> GetByUserIdAsync(int userId);
    Task AddAsync(EmailVerificationToken token);
}