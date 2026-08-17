using HomeFix.API.DTOs.SupportTicket;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SupportTicketsController : ControllerBase
{
    private readonly ISupportTicketService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public SupportTicketsController(
        ISupportTicketService service,
        IServiceRequestService requests,
        ICustomerProfileService customers,
        ITechnicianProfileService technicians)
    {
        _service = service;
        _requests = requests;
        _customers = customers;
        _technicians = technicians;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SupportTicketDto>> GetById(int id)
    {
        var ticket = await _service.GetByIdAsync(id);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();
        return Ok(MapToDto(ticket));
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<List<SupportTicketDto>>> GetByUserId(int userId)
    {
        if (!TryGetUserId(out var currentUserId)) return Unauthorized();
        if (!User.IsInRole("Admin") && currentUserId != userId) return Forbid();

        var tickets = await _service.GetByUserIdAsync(userId);
        return Ok(tickets.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("status/{status}")]
    public async Task<ActionResult<List<SupportTicketDto>>> GetByStatus(string status)
    {
        var tickets = await _service.GetByStatusAsync(status);
        return Ok(tickets.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<SupportTicketDto>> Create(CreateSupportTicketRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();

        if (request.ServiceRequestId > 0)
        {
            var serviceRequest = await _requests.GetByIdAsync(request.ServiceRequestId);
            if (serviceRequest == null)
                return BadRequest(new { message = "Service request not found." });

            if (!User.IsInRole("Admin"))
            {
                var authorized = false;
                if (User.IsInRole("Customer"))
                {
                    var customer = await _customers.GetByUserIdAsync(userId);
                    authorized = customer != null && customer.Id == serviceRequest.CustomerId;
                }
                else if (User.IsInRole("Technician"))
                {
                    var technician = await _technicians.GetByUserIdAsync(userId);
                    authorized = technician != null &&
                                 serviceRequest.Booking?.TechnicianId == technician.Id;
                }

                if (!authorized) return Forbid();
            }
        }

        var ticket = new SupportTicket
        {
            UserId = userId,
            ServiceRequestId = request.ServiceRequestId,
            Subject = request.Subject?.Trim(),
            Description = request.Description?.Trim(),
            Priority = string.IsNullOrWhiteSpace(request.Priority) ? "Medium" : request.Priority.Trim(),
            Status = "Open",
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(ticket);
        return CreatedAtAction(nameof(GetById), new { id = ticket.Id }, MapToDto(ticket));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<SupportTicketDto>> Update(int id, UpdateSupportTicketRequest request)
    {
        var ticket = await _service.GetByIdAsync(id);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();

        ticket.Description = request.Description?.Trim();
        if (User.IsInRole("Admin"))
        {
            ticket.Status = request.Status?.Trim() ?? ticket.Status;
            ticket.Priority = request.Priority?.Trim() ?? ticket.Priority;
        }
        ticket.UpdatedAt = DateTime.UtcNow;

        await _service.UpdateAsync(ticket);
        return Ok(MapToDto(ticket));
    }

    private bool CanAccess(int ownerUserId)
    {
        if (User.IsInRole("Admin")) return true;
        return int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)
               && userId == ownerUserId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static SupportTicketDto MapToDto(SupportTicket ticket) => new()
    {
        Id = ticket.Id,
        UserId = ticket.UserId,
        ServiceRequestId = ticket.ServiceRequestId,
        Subject = ticket.Subject,
        Description = ticket.Description,
        Status = ticket.Status,
        Priority = ticket.Priority,
        CreatedAt = ticket.CreatedAt,
        UpdatedAt = ticket.UpdatedAt
    };
}