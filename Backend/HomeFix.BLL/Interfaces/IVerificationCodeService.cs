namespace HomeFix.BLL.Interfaces;

public interface IVerificationCodeService
{
    Task<(bool Success, string? Error)> IssueAsync(int userId, string purpose, string channel);
    Task<(bool Success, string? Error)> VerifyAsync(int userId, string purpose, string channel, string code);
    Task<(bool Success, string? Error, string? DevelopmentCode)> IssueForBookingAsync(int userId, int bookingId, string purpose, string channel);
    Task<(bool Success, string? Error)> VerifyBookingAsync(int userId, int bookingId, string purpose, string channel, string code);
}
