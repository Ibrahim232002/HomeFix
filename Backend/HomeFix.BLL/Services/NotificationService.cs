using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class NotificationService : INotificationService
{
    private readonly NotificationRepository _repository;

    public NotificationService(NotificationRepository repository)
    {
        _repository = repository;
    }

    public Task<List<Notification>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<Notification?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task AddAsync(Notification notification)
        => _repository.AddAsync(notification);

    public Task UpdateAsync(Notification notification)
        => _repository.UpdateAsync(notification);
}