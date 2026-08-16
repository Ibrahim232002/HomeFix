using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class UserDeviceRepository
{
    private readonly HomeFixDbContext _context;
    public UserDeviceRepository(HomeFixDbContext context) => _context = context;

    public Task<UserDevice?> GetByTokenAsync(string deviceToken) => _context.UserDevices.FirstOrDefaultAsync(x => x.DeviceToken == deviceToken);
    public Task<List<UserDevice>> GetActiveByUserIdAsync(int userId) => _context.UserDevices.Where(x => x.UserId == userId && x.IsActive).OrderByDescending(x => x.LastSeenAt).ToListAsync();
    public Task AddAsync(UserDevice device) => _context.UserDevices.AddAsync(device).AsTask();
    public void Update(UserDevice device) => _context.UserDevices.Update(device);
}
