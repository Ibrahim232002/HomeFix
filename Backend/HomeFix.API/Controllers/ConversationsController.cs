using HomeFix.API.DTOs.Conversation;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ConversationsController : ControllerBase
{
    private readonly IConversationService _service;
    private readonly IBookingService _bookings;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public ConversationsController(
        IConversationService service,
        IBookingService bookings,
        ICustomerProfileService customers,
        ITechnicianProfileService technicians)
    {
        _service = service;
        _bookings = bookings;
        _customers = customers;
        _technicians = technicians;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ConversationDto>> GetById(int id)
    {
        var conversation = await _service.GetByIdAsync(id);
        if (conversation == null) return NotFound();
        if (!await CanAccessAsync(conversation)) return Forbid();
        return Ok(MapToDto(conversation));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<ConversationDto>> GetByRequestId(int serviceRequestId)
    {
        var conversation = await _service.GetByRequestIdAsync(serviceRequestId);
        if (conversation == null) return NotFound();
        if (!await CanAccessAsync(conversation)) return Forbid();
        return Ok(MapToDto(conversation));
    }

    [HttpGet("customer/{customerId:int}")]
    public async Task<ActionResult<List<ConversationDto>>> GetByCustomerId(int customerId)
    {
        if (!await IsCustomerOwnerAsync(customerId)) return Forbid();
        var conversations = await _service.GetByCustomerIdAsync(customerId);
        return Ok(conversations.Select(MapToDto).ToList());
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<ConversationDto>>> GetByTechnicianId(int technicianId)
    {
        if (!await IsTechnicianOwnerAsync(technicianId)) return Forbid();
        var conversations = await _service.GetByTechnicianIdAsync(technicianId);
        return Ok(conversations.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ConversationDto>> Create(CreateConversationRequest request)
    {
        if (request.ServiceRequestId <= 0)
            return BadRequest(new { message = "A valid service request is required." });

        var booking = await _bookings.GetByRequestIdAsync(request.ServiceRequestId);
        if (booking == null) return BadRequest(new { message = "A confirmed booking is required before creating a conversation." });
        if (!await IsParticipantAsync(booking)) return Forbid();

        // Conversation is one-per-service-request. Return the existing conversation
        // instead of generating a duplicate request under retries.
        var existing = await _service.GetByRequestIdAsync(request.ServiceRequestId);
        if (existing != null)
            return Ok(MapToDto(existing));

        var conversation = new Conversation
        {
            ServiceRequestId = request.ServiceRequestId,
            CustomerId = booking.ServiceRequest.CustomerId,
            TechnicianId = booking.TechnicianId,
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            await _service.AddAsync(conversation);
        }
        catch (DbUpdateException)
        {
            var racedConversation = await _service.GetByRequestIdAsync(request.ServiceRequestId);
            if (racedConversation != null)
                return Ok(MapToDto(racedConversation));
            throw;
        }

        return CreatedAtAction(nameof(GetById), new { id = conversation.Id }, MapToDto(conversation));
    }

    private async Task<bool> IsParticipantAsync(HomeFix.DAL.Entities.Booking booking)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && booking.ServiceRequest.CustomerId == customer.Id;
        }
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && booking.TechnicianId == technician.Id;
        }
        return false;
    }

    private async Task<bool> CanAccessAsync(Conversation conversation)
    {
        if (User.IsInRole("Admin")) return true;
        if (User.IsInRole("Customer")) return await IsCustomerOwnerAsync(conversation.CustomerId);
        if (User.IsInRole("Technician")) return await IsTechnicianOwnerAsync(conversation.TechnicianId);
        return false;
    }

    private async Task<bool> IsCustomerOwnerAsync(int customerId)
    {
        if (!TryGetUserId(out var userId)) return false;
        var customer = await _customers.GetByUserIdAsync(userId);
        return customer != null && customer.Id == customerId;
    }

    private async Task<bool> IsTechnicianOwnerAsync(int technicianId)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        var technician = await _technicians.GetByUserIdAsync(userId);
        return technician != null && technician.Id == technicianId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static ConversationDto MapToDto(Conversation conversation) => new()
    {
        Id = conversation.Id,
        ServiceRequestId = conversation.ServiceRequestId,
        CustomerId = conversation.CustomerId,
        TechnicianId = conversation.TechnicianId,
        CreatedAt = conversation.CreatedAt
    };
}