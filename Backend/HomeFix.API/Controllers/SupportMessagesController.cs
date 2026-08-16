using HomeFix.API.DTOs.SupportMessage;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SupportMessagesController : ControllerBase
{
    private readonly ISupportMessageService _service;
    private readonly ISupportTicketService _tickets;

    public SupportMessagesController(
        ISupportMessageService service,
        ISupportTicketService tickets)
    {
        _service = service;
        _tickets = tickets;
    }

    [HttpGet("ticket/{supportTicketId:int}")]
    public async Task<ActionResult<List<SupportMessageDto>>>
        GetByTicketId(int supportTicketId)
    {
        var ticket = await _tickets.GetByIdAsync(supportTicketId);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();
        var messages = await _service.GetByTicketIdAsync(supportTicketId);

        return Ok(messages.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<SupportMessageDto>> Create(
        CreateSupportMessageRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var ticket = await _tickets.GetByIdAsync(request.SupportTicketId);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();

        var message = new SupportMessage
        {
            SupportTicketId = request.SupportTicketId,
            SenderId = userId,
            Message = request.Message,
            AttachmentUrl = request.AttachmentUrl,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(message);

        return Ok(MapToDto(message));
    }

    private bool CanAccess(int ownerUserId)
    {
        if (User.IsInRole("Admin")) return true;
        return int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)
               && userId == ownerUserId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static SupportMessageDto MapToDto(
        SupportMessage message)
    {
        return new SupportMessageDto
        {
            Id = message.Id,
            SupportTicketId = message.SupportTicketId,
            SenderId = message.SenderId,
            Message = message.Message,
            AttachmentUrl = message.AttachmentUrl,
            CreatedAt = message.CreatedAt
        };
    }
}