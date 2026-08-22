using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PasswordResetTokenService : IPasswordResetTokenService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly PasswordResetTokenRepository _repository;

    public PasswordResetTokenService(
        PasswordResetTokenRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<PasswordResetToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<PasswordResetToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public async Task AddAsync(PasswordResetToken token)
        {
        await _repository.AddAsync(token);
        await _unitOfWork.SaveChangesAsync();
    }
}
