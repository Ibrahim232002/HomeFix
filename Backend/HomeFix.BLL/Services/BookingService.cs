using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

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

    public async Task<Booking?> GetByIdAsync(int id)
    {
        return await _bookingRepository.GetByIdAsync(id);
    }

    public async Task<Booking?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _bookingRepository
            .GetByRequestIdAsync(serviceRequestId);
    }

    public async Task<List<Booking>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _bookingRepository
            .GetByTechnicianIdAsync(technicianId);
    }

    public async Task CreateAsync(Booking booking)
    {
        await _bookingRepository.AddAsync(booking);
    }

    public async Task UpdateAsync(Booking booking)
    {
        await _bookingRepository.UpdateAsync(booking);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<(bool Success, string? Error)> TransitionStatusAsync(int bookingId, string newStatus, decimal? finalPrice, string? technicianNotes)
    {
        var booking = await _bookingRepository.GetByIdAsync(bookingId);
        if (booking == null) return (false, "Booking not found.");

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
            return (false, $"Invalid booking status transition from {booking.Status} to {newStatus}.");

        if (finalPrice.HasValue && newStatus != "Completed")
            return (false, "Final price can only be set when completing the booking.");

        var now = DateTime.UtcNow;
        booking.Status = newStatus;

        if (newStatus == "TechnicianOnTheWay") booking.AcceptedAt ??= now;
        if (newStatus == "Arrived") booking.ArrivedAt = now;
        if (newStatus == "InProgress") booking.StartedAt = now;

        if (newStatus == "Completed")
        {
            booking.CompletedAt = now;
            booking.FinalPrice = finalPrice ?? booking.FinalPrice ?? booking.AgreedPrice;
        }

        if (!string.IsNullOrWhiteSpace(technicianNotes))
            booking.TechnicianNotes = technicianNotes;

        await _unitOfWork.SaveChangesAsync();
        return (true, null);
    }
}
