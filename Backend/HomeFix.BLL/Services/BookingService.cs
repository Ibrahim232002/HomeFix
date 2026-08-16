using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class BookingService : IBookingService
{
    private readonly BookingRepository _bookingRepository;

    public BookingService(BookingRepository bookingRepository)
    {
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
    }
}