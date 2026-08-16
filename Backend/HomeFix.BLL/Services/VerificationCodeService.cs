using System.Security.Cryptography;
using System.Text;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.Extensions.Logging;

namespace HomeFix.BLL.Services;

public class VerificationCodeService : IVerificationCodeService
{
    private readonly VerificationCodeRepository _repository;
    private readonly UserRepository _userRepository;
    private readonly IEmailService _emailService;
    private readonly UnitOfWork _unitOfWork;
    private readonly ILogger<VerificationCodeService> _logger;

    public VerificationCodeService(
        VerificationCodeRepository repository,
        UserRepository userRepository,
        IEmailService emailService,
        UnitOfWork unitOfWork,
        ILogger<VerificationCodeService> logger)
    {
        _repository = repository;
        _userRepository = userRepository;
        _emailService = emailService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> IssueAsync(int userId, string purpose, string channel)
    {
        var recent = await _repository.GetRecentAsync(userId, purpose, channel, DateTime.UtcNow.AddMinutes(-1));
        if (recent.Count > 0) return (false, "Please wait before requesting another verification code.");

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return (false, "User not found.");

        var code = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
        var entity = new VerificationCode
        {
            UserId = userId,
            CodeHash = Hash(code),
            Purpose = purpose,
            Channel = channel,
            ExpiresAt = DateTime.UtcNow.AddMinutes(10),
            Attempts = 0,
            CreatedAt = DateTime.UtcNow
        };

        await _repository.AddAsync(entity);
        await _unitOfWork.SaveChangesAsync();

        if (channel.Equals("Email", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                await _emailService.SendCodeAsync(user.Email, code, purpose);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send {Purpose} verification code to user {UserId}.", purpose, userId);
                await _repository.DeleteAsync(entity);
                await _unitOfWork.SaveChangesAsync();
                return (false, "Verification email could not be sent. Check the server email configuration.");
            }
        }

        return (true, null);
    }

    public async Task<(bool Success, string? Error, string? DevelopmentCode)> IssueForBookingAsync(int userId, int bookingId, string purpose, string channel)
    {
        if (purpose is not ("JobStart" or "JobCompletion")) return (false, "Invalid verification purpose.", null);
        var code = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
        var entity = new VerificationCode
        {
            UserId = userId, BookingId = bookingId, CodeHash = Hash(code), Purpose = purpose, Channel = channel,
            ExpiresAt = DateTime.UtcNow.AddMinutes(10), Attempts = 0, CreatedAt = DateTime.UtcNow
        };
        await _repository.AddAsync(entity);
        await _unitOfWork.SaveChangesAsync();
        return (true, null, code);
    }

    public async Task<(bool Success, string? Error)> VerifyBookingAsync(int userId, int bookingId, string purpose, string channel, string code)
    {
        var current = await _repository.GetLatestForBookingAsync(userId, bookingId, purpose, channel);
        if (current == null) return (false, "Verification code not found.");
        if (current.ExpiresAt <= DateTime.UtcNow) return (false, "Verification code has expired.");
        if (current.Attempts >= 5) return (false, "Too many verification attempts.");
        current.Attempts++;
        if (!CryptographicEquals(current.CodeHash, Hash(code)))
        {
            await _unitOfWork.SaveChangesAsync();
            return (false, "Invalid verification code.");
        }
        current.UsedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Success, string? Error)> VerifyAsync(int userId, string purpose, string channel, string code)
    {
        var current = await _repository.GetLatestAsync(userId, purpose, channel);
        if (current == null) return (false, "Verification code not found.");
        if (current.ExpiresAt <= DateTime.UtcNow) return (false, "Verification code has expired.");
        if (current.Attempts >= 5) return (false, "Too many verification attempts.");

        current.Attempts++;
        if (!CryptographicEquals(current.CodeHash, Hash(code)))
        {
            await _unitOfWork.SaveChangesAsync();
            return (false, "Invalid verification code.");
        }

        current.UsedAt = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }

    private static string Hash(string value)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(value));
        return Convert.ToHexString(bytes);
    }

    private static bool CryptographicEquals(string left, string right)
        => CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(left), Encoding.UTF8.GetBytes(right));
}
