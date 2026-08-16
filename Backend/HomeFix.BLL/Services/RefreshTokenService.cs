using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly RefreshTokenRepository _repository;

    public RefreshTokenService(RefreshTokenRepository repository)
    {
        _repository = repository;
    }

    public Task<RefreshToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<RefreshToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task AddAsync(RefreshToken refreshToken)
        => _repository.AddAsync(refreshToken);

    public Task UpdateAsync(RefreshToken refreshToken)
        => _repository.UpdateAsync(refreshToken);
}