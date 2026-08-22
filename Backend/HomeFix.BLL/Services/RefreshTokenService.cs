using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly RefreshTokenRepository _repository;

    public RefreshTokenService(RefreshTokenRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<RefreshToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<RefreshToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public async Task AddAsync(RefreshToken refreshToken)
        {
        await _repository.AddAsync(refreshToken);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(RefreshToken refreshToken)
        {
        await _repository.UpdateAsync(refreshToken);
        await _unitOfWork.SaveChangesAsync();
    }
}
