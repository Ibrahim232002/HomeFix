using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class EmailVerificationTokenService : IEmailVerificationTokenService
{
    private readonly EmailVerificationTokenRepository _repository;

    public EmailVerificationTokenService(
        EmailVerificationTokenRepository repository)
    {
        _repository = repository;
    }

    public Task<EmailVerificationToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<EmailVerificationToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task AddAsync(EmailVerificationToken token)
        => _repository.AddAsync(token);
}