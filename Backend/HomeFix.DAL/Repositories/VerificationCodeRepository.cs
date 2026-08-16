using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class VerificationCodeRepository
{
    private readonly HomeFixDbContext _context;
    public VerificationCodeRepository(HomeFixDbContext context) => _context = context;

    public Task<VerificationCode?> GetLatestAsync(int userId, string purpose, string channel) =>
        _context.VerificationCodes
            .Where(x => x.UserId == userId && x.Purpose == purpose && x.Channel == channel && x.UsedAt == null)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync();

    public Task<VerificationCode?> GetLatestForBookingAsync(int userId, int bookingId, string purpose, string channel) =>
        _context.VerificationCodes
            .Where(x => x.UserId == userId && x.BookingId == bookingId && x.Purpose == purpose && x.Channel == channel && x.UsedAt == null)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync();

    public Task<List<VerificationCode>> GetRecentAsync(int userId, string purpose, string channel, DateTime since) =>
        _context.VerificationCodes
            .Where(x => x.UserId == userId && x.Purpose == purpose && x.Channel == channel && x.CreatedAt >= since)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

    public Task<List<VerificationCode>> GetRecentForBookingAsync(int userId, int bookingId, string purpose, string channel, DateTime since) =>
        _context.VerificationCodes
            .Where(x => x.UserId == userId && x.BookingId == bookingId && x.Purpose == purpose && x.Channel == channel && x.CreatedAt >= since)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

    public Task AddAsync(VerificationCode code) => _context.VerificationCodes.AddAsync(code).AsTask();

    public Task DeleteAsync(VerificationCode code)
    {
        _context.VerificationCodes.Remove(code);
        return Task.CompletedTask;
    }
}
