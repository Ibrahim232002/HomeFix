using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class NotificationService : INotificationService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly NotificationRepository _repository;

    public NotificationService(NotificationRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<Notification>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<Notification?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public async Task AddAsync(Notification notification)
        {
        await _repository.AddAsync(notification);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Notification notification)
        {
        await _repository.UpdateAsync(notification);
        await _unitOfWork.SaveChangesAsync();
    }
}
