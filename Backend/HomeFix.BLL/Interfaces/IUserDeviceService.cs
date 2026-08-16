using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IUserDeviceService
{
    Task<List<UserDevice>> GetActiveAsync(int userId);
    Task<UserDevice> RegisterOrUpdateAsync(int userId, string deviceToken, string platform);
    Task<bool> DeactivateAsync(int userId, string deviceToken);
}
