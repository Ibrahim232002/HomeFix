using System.Security.Cryptography;
using Google.Apis.Auth;
using HomeFix.BLL.Interfaces;
using HomeFix.BLL.Models;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.Extensions.Options;

namespace HomeFix.BLL.Services;

public class AuthService : IAuthService
{
    private readonly UserRepository _userRepository;
    private readonly CustomerProfileRepository _customerProfileRepository;
    private readonly TechnicianProfileRepository _technicianProfileRepository;
    private readonly TechnicianWalletRepository _technicianWalletRepository;
    private readonly RefreshTokenRepository _refreshTokenRepository;
    private readonly ExternalLoginRepository _externalLoginRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IVerificationCodeService _verificationCodeService;
    private readonly UnitOfWork _unitOfWork;
    private readonly JwtSettings _jwtSettings;
    private readonly GoogleSettings _googleSettings;

    public AuthService(UserRepository userRepository, CustomerProfileRepository customerProfileRepository, TechnicianProfileRepository technicianProfileRepository, TechnicianWalletRepository technicianWalletRepository, RefreshTokenRepository refreshTokenRepository, ExternalLoginRepository externalLoginRepository, IPasswordHasher passwordHasher, IVerificationCodeService verificationCodeService, IOptions<JwtSettings> jwtSettings, IOptions<GoogleSettings> googleSettings, UnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _customerProfileRepository = customerProfileRepository;
        _technicianProfileRepository = technicianProfileRepository;
        _technicianWalletRepository = technicianWalletRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _externalLoginRepository = externalLoginRepository;
        _passwordHasher = passwordHasher;
        _verificationCodeService = verificationCodeService;
        _jwtSettings = jwtSettings.Value;
        _googleSettings = googleSettings.Value;
        _unitOfWork = unitOfWork;
    }

    public async Task<(bool Success, string? Error, User? User)> RegisterAsync(string fullName, string email, string phoneNumber, string password, string role)
    {
        if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(phoneNumber) || string.IsNullOrWhiteSpace(password))
            return (false, "All required fields must be provided.", null);
        if (password.Length < 8) return (false, "Password must be at least 8 characters.", null);
        var normalizedEmail = email.Trim().ToLowerInvariant();
        if (await _userRepository.EmailExistsAsync(normalizedEmail)) return (false, "Email already exists.", null);
        if (await _userRepository.PhoneExistsAsync(phoneNumber.Trim())) return (false, "Phone number already exists.", null);
        if (role is not ("Customer" or "Technician")) return (false, "Invalid role.", null);

        await using var tx = await _unitOfWork.BeginTransactionAsync();
        var user = new User
        {
            FullName = fullName.Trim(),
            Email = normalizedEmail,
            PhoneNumber = phoneNumber.Trim(),
            PasswordHash = _passwordHasher.Hash(password),
            Role = role,
            IsActive = true,
            IsEmailVerified = false,
            IsPhoneVerified = false,
            CreatedAt = DateTime.UtcNow
        };
        await _userRepository.AddAsync(user);
        await _unitOfWork.SaveChangesAsync();

        if (role == "Customer")
        {
            await _customerProfileRepository.AddAsync(new CustomerProfile { UserId = user.Id, CreatedAt = DateTime.UtcNow });
        }
        else
        {
            var technician = new TechnicianProfile { UserId = user.Id, IsAvailable = false, IsVerified = false, AverageRating = 0, TotalJobs = 0, CreatedAt = DateTime.UtcNow };
            await _technicianProfileRepository.AddAsync(technician);
            await _unitOfWork.SaveChangesAsync();
            await _technicianWalletRepository.AddAsync(new TechnicianWallet { TechnicianId = technician.Id, Balance = 0, UpdatedAt = DateTime.UtcNow });
        }

        await _unitOfWork.SaveChangesAsync();
        var otp = await _verificationCodeService.IssueAsync(user.Id, "EmailVerification", "Email");
        if (!otp.Success)
        {
            await tx.RollbackAsync();
            return (false, otp.Error, null);
        }
        await tx.CommitAsync();
        return (true, null, user);
    }

    public async Task<(bool Success, string? Error, User? User)> ValidateLoginAsync(string email, string password)
    {
        var user = await _userRepository.GetByEmailAsync(email.Trim().ToLowerInvariant());
        if (user == null || !_passwordHasher.Verify(password, user.PasswordHash)) return (false, "Invalid email or password.", null);
        if (!user.IsActive) return (false, "User account is inactive.", null);
        if (!user.IsEmailVerified) return (false, "Email address is not verified.", user);

        if (_passwordHasher.NeedsRehash(user.PasswordHash))
        {
            user.PasswordHash = _passwordHasher.Hash(password);
            await _unitOfWork.SaveChangesAsync();
        }

        return (true, null, user);
    }

    public async Task<string> CreateRefreshTokenAsync(User user)
    {
        var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            TokenHash = HashRefreshToken(token),
            ExpiresAt = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays),
            CreatedAt = DateTime.UtcNow,
            RevokedAt = null
        };
        await _refreshTokenRepository.AddAsync(refreshToken);
        await _unitOfWork.SaveChangesAsync();
        return token;
    }

    public async Task<(bool Success, string? Error, User? User)> ValidateRefreshTokenAsync(string refreshToken)
    {
        var token = await _refreshTokenRepository.GetByHashAsync(HashRefreshToken(refreshToken));
        if (token == null || token.RevokedAt != null || token.ExpiresAt <= DateTime.UtcNow || !token.User.IsActive) return (false, "Invalid or expired refresh token.", null);
        return (true, null, token.User);
    }

    public async Task<bool> RevokeRefreshTokenAsync(string refreshToken)
    {
        var token = await _refreshTokenRepository.GetByHashAsync(HashRefreshToken(refreshToken));
        if (token == null || token.RevokedAt != null) return false;
        token.RevokedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<(bool Success, string? Error)> VerifyEmailAsync(string email, string code)
    {
        var user = await _userRepository.GetByEmailAsync(email.Trim().ToLowerInvariant());
        if (user == null) return (false, "Invalid verification request.");
        if (user.IsEmailVerified) return (true, null);
        var result = await _verificationCodeService.VerifyAsync(user.Id, "EmailVerification", "Email", code);
        if (!result.Success) return result;
        user.IsEmailVerified = true;
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Success, string? Error)> RequestPasswordResetAsync(string email)
    {
        var user = await _userRepository.GetByEmailAsync(email.Trim().ToLowerInvariant());
        if (user == null) return (true, null);
        return await _verificationCodeService.IssueAsync(user.Id, "PasswordReset", "Email");
    }

    public async Task<(bool Success, string? Error)> ResetPasswordAsync(string email, string code, string newPassword)
    {
        if (newPassword.Length < 8) return (false, "Password must be at least 8 characters.");
        var user = await _userRepository.GetByEmailAsync(email.Trim().ToLowerInvariant());
        if (user == null) return (false, "Invalid reset request.");
        var result = await _verificationCodeService.VerifyAsync(user.Id, "PasswordReset", "Email", code);
        if (!result.Success) return result;
        user.PasswordHash = _passwordHasher.Hash(newPassword);
        var tokens = await _refreshTokenRepository.GetByUserIdAsync(user.Id);
        foreach (var token in tokens.Where(t => t.RevokedAt == null)) token.RevokedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Success, string? Error, User? User)> GoogleLoginAsync(string idToken)
    {
        if (string.IsNullOrWhiteSpace(_googleSettings.ClientId)) return (false, "Google Sign-In is not configured on the server.", null);
        GoogleJsonWebSignature.Payload payload;
        try
        {
            payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = new[] { _googleSettings.ClientId }
            });
        }
        catch
        {
            return (false, "Invalid Google identity token.", null);
        }

        if (string.IsNullOrWhiteSpace(payload.Subject) || string.IsNullOrWhiteSpace(payload.Email)) return (false, "Google account did not provide the required identity claims.", null);

        var external = await _externalLoginRepository.GetAsync("Google", payload.Subject);
        if (external != null)
        {
            if (!external.User.IsActive) return (false, "User account is inactive.", null);
            if (!external.User.IsEmailVerified) { external.User.IsEmailVerified = true; await _unitOfWork.SaveChangesAsync(); }
            return (true, null, external.User);
        }

        var existingUser = await _userRepository.GetByEmailAsync(payload.Email.Trim().ToLowerInvariant());
        User user;
        if (existingUser != null)
        {
            if (!existingUser.IsActive) return (false, "User account is inactive.", null);
            existingUser.IsEmailVerified = true;
            user = existingUser;
        }
        else
        {
            await using var tx = await _unitOfWork.BeginTransactionAsync();
            user = new User
            {
                FullName = string.IsNullOrWhiteSpace(payload.Name) ? payload.Email.Split('@')[0] : payload.Name,
                Email = payload.Email.Trim().ToLowerInvariant(),
                PhoneNumber = "GOOGLE_PENDING",
                PasswordHash = _passwordHasher.Hash(Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))),
                Role = "Customer",
                IsActive = true,
                IsEmailVerified = true,
                IsPhoneVerified = false,
                CreatedAt = DateTime.UtcNow
            };
            while (await _userRepository.PhoneExistsAsync(user.PhoneNumber)) user.PhoneNumber = "GOOGLE_" + Convert.ToHexString(RandomNumberGenerator.GetBytes(8));
            await _userRepository.AddAsync(user);
            await _unitOfWork.SaveChangesAsync();
            await _customerProfileRepository.AddAsync(new CustomerProfile { UserId = user.Id, CreatedAt = DateTime.UtcNow });
            await _externalLoginRepository.AddAsync(new ExternalLogin { UserId = user.Id, Provider = "Google", ProviderSubjectId = payload.Subject, Email = user.Email, CreatedAt = DateTime.UtcNow });
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();
        }

        if (!await _externalLoginRepository.ExistsForUserAsync(user.Id, "Google"))
        {
            await _externalLoginRepository.AddAsync(new ExternalLogin { UserId = user.Id, Provider = "Google", ProviderSubjectId = payload.Subject, Email = user.Email, CreatedAt = DateTime.UtcNow });
            await _unitOfWork.SaveChangesAsync();
        }
        return (true, null, user);
    }

    private static string HashRefreshToken(string token)
        => Convert.ToHexString(SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(token)));
}
