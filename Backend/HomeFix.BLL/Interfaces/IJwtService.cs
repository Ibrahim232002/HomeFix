using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(User user);
    string GenerateRefreshToken();
}