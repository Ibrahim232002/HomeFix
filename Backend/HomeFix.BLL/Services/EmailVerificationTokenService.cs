using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class EmailVerificationTokenService : IEmailVerificationTokenService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly EmailVerificationTokenRepository _repository;

    public EmailVerificationTokenService(
        EmailVerificationTokenRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<EmailVerificationToken?> GetByTokenAsync(string token)
        => _repository.GetByTokenAsync(token);

    public Task<List<EmailVerificationToken>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public async Task AddAsync(EmailVerificationToken token)
        {
        await _repository.AddAsync(token);
        await _unitOfWork.SaveChangesAsync();
    }
}
