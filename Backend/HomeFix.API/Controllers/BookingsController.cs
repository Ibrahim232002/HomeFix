using HomeFix.API.DTOs.Booking;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _service;

    public BookingsController(IBookingService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookingDto>> GetById(int id)
    {
        var booking = await _service.GetByIdAsync(id);

        if (booking == null)
            return NotFound();

        return Ok(MapToDto(booking));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<BookingDto>> GetByRequestId(
        int serviceRequestId)
    {
        var booking =
            await _service.GetByRequestIdAsync(serviceRequestId);

        if (booking == null)
            return NotFound();

        return Ok(MapToDto(booking));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<BookingDto>>> GetByTechnicianId(
        int technicianId)
    {
        var bookings =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(bookings.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<BookingDto>> Create(
        CreateBookingRequest request)
    {
        var booking = new Booking
        {
            ServiceRequestId = request.ServiceRequestId,
            TechnicianId = request.TechnicianId
        };

        await _service.CreateAsync(booking);

        return CreatedAtAction(
            nameof(GetById),
            new { id = booking.Id },
            MapToDto(booking));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<BookingDto>> Update(
        int id,
        UpdateBookingRequest request)
    {
        var booking = await _service.GetByIdAsync(id);

        if (booking == null)
            return NotFound();

        booking.AcceptedAt = request.AcceptedAt;
        booking.ArrivedAt = request.ArrivedAt;
        booking.StartedAt = request.StartedAt;
        booking.CompletedAt = request.CompletedAt;
        booking.FinalPrice = request.FinalPrice;
        booking.TechnicianNotes = request.TechnicianNotes;

        await _service.UpdateAsync(booking);

        return Ok(MapToDto(booking));
    }

    private static BookingDto MapToDto(Booking booking)
    {
        return new BookingDto
        {
            Id = booking.Id,
            ServiceRequestId = booking.ServiceRequestId,
            TechnicianId = booking.TechnicianId,
            AcceptedAt = booking.AcceptedAt,
            ArrivedAt = booking.ArrivedAt,
            StartedAt = booking.StartedAt,
            CompletedAt = booking.CompletedAt,
            FinalPrice = booking.FinalPrice,
            TechnicianNotes = booking.TechnicianNotes
        };
    }
}