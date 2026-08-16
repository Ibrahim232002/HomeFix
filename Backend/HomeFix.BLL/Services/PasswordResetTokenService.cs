using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PasswordResetTokenService : IPasswordResetTokenService
{
    private readonly PasswordResetTokenRepository _repository;

    public PasswordResetTokenService(
        PasswordResetTokenRepository repository)
    {
        _repository = repository;
    }

    public Task<PasswordResetToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<PasswordResetToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task AddAsync(PasswordResetToken token)
        => _repository.AddAsync(token);
}