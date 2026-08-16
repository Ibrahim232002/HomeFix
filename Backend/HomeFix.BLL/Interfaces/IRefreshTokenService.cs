using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IRefreshTokenService
{
    Task<RefreshToken?> GetByTokenAsync(string token);
    Task<List<RefreshToken>> GetByUserIdAsync(int userId);
    Task AddAsync(RefreshToken refreshToken);
    Task UpdateAsync(RefreshToken refreshToken);
}