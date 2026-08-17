using HomeFix.API.DTOs.Booking;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _service;
    private readonly ICustomerProfileService _customerProfiles;
    private readonly ITechnicianProfileService _technicianProfiles;
    private readonly IVerificationCodeService _verificationCodes;

    public BookingsController(IBookingService service, ICustomerProfileService customerProfiles, ITechnicianProfileService technicianProfiles, IVerificationCodeService verificationCodes)
    { _service = service; _customerProfiles = customerProfiles; _technicianProfiles = technicianProfiles; _verificationCodes = verificationCodes; }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookingDto>> GetById(int id)
    {
        var booking = await _service.GetByIdAsync(id);
        if (booking == null) return NotFound();
        if (!await IsParticipantAsync(booking) && !User.IsInRole("Admin")) return Forbid();
        return Ok(MapToDto(booking));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<BookingDto>> GetByRequestId(int serviceRequestId)
    {
        var booking = await _service.GetByRequestIdAsync(serviceRequestId);
        if (booking == null) return NotFound();
        if (!await IsParticipantAsync(booking) && !User.IsInRole("Admin")) return Forbid();
        return Ok(MapToDto(booking));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<BookingDto>>> GetByTechnicianId(int technicianId)
    {
        if (!User.IsInRole("Admin"))
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || technician.Id != technicianId) return Forbid();
        }
        var bookings = await _service.GetByTechnicianIdAsync(technicianId);
        return Ok(bookings.Select(MapToDto).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BookingDto>> Create(CreateBookingRequest request)
    {
        var booking = new Booking { ServiceRequestId = request.ServiceRequestId, TechnicianId = request.TechnicianId, Status = "Confirmed" };
        await _service.CreateAsync(booking);
        return CreatedAtAction(nameof(GetById), new { id = booking.Id }, MapToDto(booking));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BookingDto>> Update(int id, UpdateBookingRequest request)
    {
        var booking = await _service.GetByIdAsync(id);
        if (booking == null) return NotFound();
        if (request.Status != null) booking.Status = request.Status;
        if (request.AgreedPrice.HasValue) booking.AgreedPrice = request.AgreedPrice;
        booking.FinalPrice = request.FinalPrice ?? booking.FinalPrice;
        booking.TechnicianNotes = request.TechnicianNotes ?? booking.TechnicianNotes;
        await _service.UpdateAsync(booking);
        return Ok(MapToDto(booking));
    }

    [HttpPost("{id:int}/transition")]
    [Authorize(Roles = "Technician,Admin")]
    public async Task<IActionResult> Transition(int id, UpdateBookingRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Status)) return BadRequest(new { message = "Status is required." });
        if (request.FinalPrice.HasValue && !string.Equals(request.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { message = "Final price can only be set when completing the booking." });
        if (!User.IsInRole("Admin") && !await TechnicianOwnsBookingAsync(id)) return Forbid();

        if (request.FinalPrice.HasValue && request.FinalPrice.Value <= 0)
            return BadRequest(new { message = "Final price must be greater than zero." });

        var result = await _service.TransitionStatusAsync(id, request.Status, request.FinalPrice, request.TechnicianNotes);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(MapToDto((await _service.GetByIdAsync(id))!));
    }

    [HttpPost("{id:int}/verification-code")]
    [Authorize(Roles = "Customer,Technician")]
    [EnableRateLimiting("verification")]
    public async Task<IActionResult> IssueVerificationCode(int id, [FromQuery] string purpose)
    {
        if (purpose is not ("JobStart" or "JobCompletion"))
            return BadRequest(new { message = "Invalid verification purpose." });

        if (!TryGetUserId(out var userId)) return Unauthorized();
        var booking = await _service.GetByIdAsync(id);
        if (booking == null) return NotFound();
        if (!await IsParticipantAsync(booking)) return Forbid();

        if (purpose == "JobCompletion")
        {
            if (!User.IsInRole("Customer")) return Forbid();
            var customer = await _customerProfiles.GetByUserIdAsync(userId);
            if (customer == null || booking.ServiceRequest?.CustomerId != customer.Id) return Forbid();
        }
        else
        {
            if (!User.IsInRole("Technician")) return Forbid();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || booking.TechnicianId != technician.Id) return Forbid();
        }

        var result = await _verificationCodes.IssueForBookingAsync(userId, id, purpose, "Email");
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Verification code issued.", developmentCode = HttpContext.RequestServices.GetRequiredService<IHostEnvironment>().IsDevelopment() ? result.DevelopmentCode : null });
    }

    [HttpPost("{id:int}/verify-code")]
    [Authorize(Roles = "Customer,Technician")]
    [EnableRateLimiting("verification")]
    public async Task<IActionResult> VerifyCode(int id, [FromQuery] string purpose, [FromBody] string code)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var booking = await _service.GetByIdAsync(id);
        if (booking == null) return NotFound();
        if (!await IsParticipantAsync(booking)) return Forbid();
        if (purpose is not ("JobStart" or "JobCompletion")) return BadRequest(new { message = "Invalid verification purpose." });

        if (purpose == "JobStart")
        {
            if (!User.IsInRole("Technician")) return Forbid();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || booking.TechnicianId != technician.Id) return Forbid();
            if (booking.Status != "Arrived")
                return BadRequest(new { message = "Technician must verify after arrival." });
        }
        else
        {
            if (!User.IsInRole("Customer")) return Forbid();
            var customer = await _customerProfiles.GetByUserIdAsync(userId);
            if (customer == null || booking.ServiceRequest?.CustomerId != customer.Id) return Forbid();
            if (booking.Status != "AwaitingCompletion")
                return BadRequest(new { message = "Customer completion confirmation is required." });
        }

        var result = await _verificationCodes.VerifyBookingAsync(userId, id, purpose, "Email", code);
        if (!result.Success) return BadRequest(new { message = result.Error });

        if (purpose == "JobStart")
        {
            var transition = await _service.TransitionStatusAsync(id, "InProgress", null, null);
            if (!transition.Success) return BadRequest(new { message = transition.Error });
        }
        else
        {
            var transition = await _service.TransitionStatusAsync(id, "Completed", null, null);
            if (!transition.Success) return BadRequest(new { message = transition.Error });
        }

        return Ok(MapToDto((await _service.GetByIdAsync(id))!));
    }

    private async Task<bool> TechnicianOwnsBookingAsync(int id)
    {
        if (!TryGetUserId(out var userId)) return false;
        var tech = await _technicianProfiles.GetByUserIdAsync(userId);
        var booking = await _service.GetByIdAsync(id);
        return tech != null && booking?.TechnicianId == tech.Id;
    }

    private async Task<bool> IsParticipantAsync(Booking booking)
    {
        if (!TryGetUserId(out var userId)) return false;
        if (booking.Technician?.UserId == userId) return true;
        var customer = await _customerProfiles.GetByUserIdAsync(userId);
        return customer != null && booking.ServiceRequest?.CustomerId == customer.Id;
    }

    private bool TryGetUserId(out int userId) => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static BookingDto MapToDto(Booking booking) => new()
    {
        Id = booking.Id,
        ServiceRequestId = booking.ServiceRequestId,
        TechnicianId = booking.TechnicianId,
        Status = booking.Status,
        AgreedPrice = booking.AgreedPrice,
        AcceptedAt = booking.AcceptedAt,
        ArrivedAt = booking.ArrivedAt,
        StartedAt = booking.StartedAt,
        CompletedAt = booking.CompletedAt,
        FinalPrice = booking.FinalPrice,
        TechnicianNotes = booking.TechnicianNotes,
        ServiceName = booking.ServiceRequest?.Service?.Name,
        TechnicianName = booking.Technician?.User?.FullName,
        CustomerName = booking.ServiceRequest?.Customer?.User?.FullName,
        CustomerPhone = booking.ServiceRequest?.Customer?.User?.PhoneNumber,
        AddressId = booking.ServiceRequest?.Address?.Id,
        AddressLabel = booking.ServiceRequest?.Address?.Label,
        FullAddress = booking.ServiceRequest?.Address?.FullAddress,
        BuildingNumber = booking.ServiceRequest?.Address?.BuildingNumber,
        FloorNumber = booking.ServiceRequest?.Address?.FloorNumber,
        ApartmentNumber = booking.ServiceRequest?.Address?.ApartmentNumber,
        AdditionalInstructions = booking.ServiceRequest?.Address?.AdditionalInstructions,
        GovernorateId = booking.ServiceRequest?.Address?.GovernorateId,
        CityId = booking.ServiceRequest?.Address?.CityId,
        GovernorateName = booking.ServiceRequest?.Address?.Governorate?.Name,
        CityName = booking.ServiceRequest?.Address?.City?.Name,
    };
}