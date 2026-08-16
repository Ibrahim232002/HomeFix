using System.Security.Cryptography;
using HomeFix.BLL.Interfaces;
using HomeFix.BLL.Models;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.Extensions.Options;

namespace HomeFix.BLL.Services;

public class AuthService : IAuthService
{
    private readonly UserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly RefreshTokenRepository _refreshTokenRepository;
    private readonly JwtSettings _jwtSettings;

    public AuthService(
        UserRepository userRepository,
        IPasswordHasher passwordHasher,
        RefreshTokenRepository refreshTokenRepository,
        IOptions<JwtSettings> jwtSettings)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtSettings = jwtSettings.Value;
    }

    public async Task<(bool Success, string? Error, User? User)> RegisterAsync(
        string fullName,
        string email,
        string phoneNumber,
        string password,
        string role)
    {
        if (string.IsNullOrWhiteSpace(fullName))
            return (false, "Full name is required.", null);

        if (string.IsNullOrWhiteSpace(email))
            return (false, "Email is required.", null);

        if (string.IsNullOrWhiteSpace(password))
            return (false, "Password is required.", null);

        if (await _userRepository.EmailExistsAsync(email))
            return (false, "Email already exists.", null);

        if (await _userRepository.PhoneExistsAsync(phoneNumber))
            return (false, "Phone number already exists.", null);

        if (role != "Customer" && role != "Technician")
            return (false, "Invalid role.", null);

        var user = new User
        {
            FullName = fullName,
            Email = email,
            PhoneNumber = phoneNumber,
            PasswordHash = _passwordHasher.Hash(password),
            Role = role,
            IsActive = true
        };

        await _userRepository.AddAsync(user);

        return (true, null, user);
    }

    public async Task<(bool Success, string? Error, User? User)> ValidateLoginAsync(
        string email,
        string password)
    {
        var user = await _userRepository.GetByEmailAsync(email);

        if (user == null)
            return (false, "Invalid email or password.", null);

        if (!user.IsActive)
            return (false, "User account is inactive.", null);

        if (!_passwordHasher.Verify(password, user.PasswordHash))
            return (false, "Invalid email or password.", null);

        return (true, null, user);
    }

    public async Task<string> CreateRefreshTokenAsync(User user)
    {
        var token = Convert.ToBase64String(
            RandomNumberGenerator.GetBytes(64));

        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = token,
            ExpiresAt = DateTime.UtcNow.AddDays(
                _jwtSettings.RefreshTokenExpirationDays),
            CreatedAt = DateTime.UtcNow,
            RevokedAt = null,
            IsRevoked = false
        };

        await _refreshTokenRepository.AddAsync(refreshToken);

        return token;
    }

    public async Task<(bool Success, string? Error, User? User)>
        ValidateRefreshTokenAsync(string refreshToken)
    {
        var token = await _refreshTokenRepository
            .GetByTokenAsync(refreshToken);

        if (token == null)
            return (false, "Invalid refresh token.", null);

        if (token.RevokedAt != null || token.IsRevoked == true)
            return (false, "Refresh token has been revoked.", null);

        if (token.ExpiresAt <= DateTime.UtcNow)
            return (false, "Refresh token has expired.", null);

        if (!token.User.IsActive)
            return (false, "User account is inactive.", null);

        return (true, null, token.User);
    }

    public async Task<bool> RevokeRefreshTokenAsync(string refreshToken)
    {
        var token = await _refreshTokenRepository
            .GetByTokenAsync(refreshToken);

        if (token == null)
            return false;

        token.RevokedAt = DateTime.UtcNow;
        token.IsRevoked = true;

        await _refreshTokenRepository.UpdateAsync(token);

        return true;
    }
}