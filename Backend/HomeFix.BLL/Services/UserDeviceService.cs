using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class UserDeviceService : IUserDeviceService
{
    private readonly UserDeviceRepository _repository;
    private readonly UnitOfWork _unitOfWork;

    public UserDeviceService(UserDeviceRepository repository, UnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public Task<List<UserDevice>> GetActiveAsync(int userId)
        => _repository.GetActiveByUserIdAsync(userId);

    public async Task<UserDevice> RegisterOrUpdateAsync(int userId, string deviceToken, string platform)
    {
        if (string.IsNullOrWhiteSpace(deviceToken))
            throw new ArgumentException("Device token is required.", nameof(deviceToken));

        if (string.IsNullOrWhiteSpace(platform))
            throw new ArgumentException("Platform is required.", nameof(platform));

        var existing = await _repository.GetByTokenAsync(deviceToken.Trim());
        var now = DateTime.UtcNow;

        if (existing is null)
        {
            existing = new UserDevice
            {
                UserId = userId,
                DeviceToken = deviceToken.Trim(),
                Platform = platform.Trim(),
                IsActive = true,
                CreatedAt = now,
                LastSeenAt = now
            };
            await _repository.AddAsync(existing);
        }
        else
        {
            existing.UserId = userId;
            existing.Platform = platform.Trim();
            existing.IsActive = true;
            existing.LastSeenAt = now;
            _repository.Update(existing);
        }

        await _unitOfWork.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeactivateAsync(int userId, string deviceToken)
    {
        var existing = await _repository.GetByTokenAsync(deviceToken.Trim());
        if (existing is null || existing.UserId != userId)
            return false;

        existing.IsActive = false;
        existing.LastSeenAt = DateTime.UtcNow;
        _repository.Update(existing);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
