using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IAuthService
{
    Task<(bool Success, string? Error, User? User)> RegisterAsync(
        string fullName,
        string email,
        string phoneNumber,
        string password,
        string role);

    Task<(bool Success, string? Error, User? User)> ValidateLoginAsync(
        string email,
        string password);

    Task<string> CreateRefreshTokenAsync(User user);

    Task<(bool Success, string? Error, User? User)>
        ValidateRefreshTokenAsync(string refreshToken);

    Task<bool> RevokeRefreshTokenAsync(string refreshToken);
}