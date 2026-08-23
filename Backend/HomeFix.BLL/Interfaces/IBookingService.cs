using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IBookingService
{
    Task<Booking?> GetByIdAsync(int id);

    Task<Booking?> GetByRequestIdAsync(int serviceRequestId);

    Task<List<Booking>> GetByTechnicianIdAsync(int technicianId);

    Task CreateAsync(Booking booking);

    Task UpdateAsync(Booking booking);
    Task<(bool Success, string? Error)> TransitionStatusAsync(int bookingId, string newStatus, decimal? finalPrice, string? technicianNotes, bool verificationConfirmed = false);
}