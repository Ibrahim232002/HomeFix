using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface INotificationService
{
    Task<List<Notification>> GetByUserIdAsync(int userId);
    Task<Notification?> GetByIdAsync(int id);
    Task AddAsync(Notification notification);
    Task UpdateAsync(Notification notification);
}