using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using System.Data;

namespace HomeFix.BLL.Services;

public class BookingService : IBookingService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly BookingRepository _bookingRepository;

    public BookingService(BookingRepository bookingRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _bookingRepository = bookingRepository;
    }

    public Task<Booking?> GetByIdAsync(int id)
        => _bookingRepository.GetByIdAsync(id);

    public Task<Booking?> GetByRequestIdAsync(int serviceRequestId)
        => _bookingRepository.GetByRequestIdAsync(serviceRequestId);

    public Task<List<Booking>> GetByTechnicianIdAsync(int technicianId)
        => _bookingRepository.GetByTechnicianIdAsync(technicianId);

    public async Task CreateAsync(Booking booking)
    {
        if (booking.ServiceRequestId <= 0)
            throw new ArgumentException("A valid service request is required.", nameof(booking));
        if (booking.TechnicianId <= 0)
            throw new ArgumentException("A valid technician is required.", nameof(booking));

        booking.Status = string.IsNullOrWhiteSpace(booking.Status) ? "Confirmed" : booking.Status;
        await _bookingRepository.AddAsync(booking);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(Booking booking)
    {
        if (booking.FinalPrice.HasValue && booking.FinalPrice.Value <= 0)
            throw new ArgumentException("Final price must be greater than zero.", nameof(booking));

        if (booking.FinalPrice.HasValue && !string.Equals(booking.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            throw new ArgumentException("Final price can only be set when the booking is Completed.", nameof(booking));

        if (booking.AgreedPrice.HasValue && booking.AgreedPrice.Value <= 0)
            throw new ArgumentException("Agreed price must be greater than zero.", nameof(booking));

        await _bookingRepository.UpdateAsync(booking);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<(bool Success, string? Error)> TransitionStatusAsync(
        int bookingId,
        string newStatus,
        decimal? finalPrice,
        string? technicianNotes,
        bool verificationConfirmed = false)
    {
        if (!verificationConfirmed && newStatus == "InProgress")
            return (false, "Job Start verification is required before starting the booking.");
        if (!verificationConfirmed && newStatus == "Completed")
            return (false, "Job Completion verification is required before completing the booking.");

        await using var transaction = await _unitOfWork.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
            {
                await transaction.RollbackAsync();
                return (false, "Booking not found.");
            }

            var allowed = booking.Status switch
            {
                "Confirmed" => newStatus is "TechnicianOnTheWay" or "Cancelled",
                "TechnicianOnTheWay" => newStatus is "Arrived" or "Cancelled",
                "Arrived" => newStatus == "InProgress",
                "InProgress" => newStatus is "AwaitingCompletion" or "Cancelled",
                "AwaitingCompletion" => newStatus == "Completed",
                _ => false
            };

            if (!allowed)
            {
                await transaction.RollbackAsync();
                return (false, $"Invalid booking status transition from {booking.Status} to {newStatus}.");
            }

            if (finalPrice.HasValue && !string.Equals(newStatus, "Completed", StringComparison.OrdinalIgnoreCase))
            {
                await transaction.RollbackAsync();
                return (false, "Final price can only be set when completing the booking.");
            }

            if (finalPrice.HasValue && finalPrice.Value <= 0)
            {
                await transaction.RollbackAsync();
                return (false, "Final price must be greater than zero.");
            }

            var now = DateTime.UtcNow;
            booking.Status = newStatus;

            if (newStatus == "TechnicianOnTheWay") booking.AcceptedAt ??= now;
            if (newStatus == "Arrived") booking.ArrivedAt = now;
            if (newStatus == "InProgress") booking.StartedAt = now;

            if (newStatus == "Completed")
            {
                booking.CompletedAt = now;
                booking.FinalPrice = finalPrice ?? booking.FinalPrice ?? booking.AgreedPrice;
                if (!booking.FinalPrice.HasValue || booking.FinalPrice.Value <= 0)
                {
                    await transaction.RollbackAsync();
                    return (false, "A valid final or agreed price is required to complete the booking.");
                }
            }

            if (!string.IsNullOrWhiteSpace(technicianNotes))
                booking.TechnicianNotes = technicianNotes;

            await _unitOfWork.SaveChangesAsync();
            await transaction.CommitAsync();
            return (true, null);
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}