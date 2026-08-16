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

    Task<(bool Success, string? Error)> VerifyEmailAsync(string email, string code);
    Task<(bool Success, string? Error)> RequestPasswordResetAsync(string email);
    Task<(bool Success, string? Error)> ResetPasswordAsync(string email, string code, string newPassword);
    Task<(bool Success, string? Error, User? User)> GoogleLoginAsync(string idToken);
}