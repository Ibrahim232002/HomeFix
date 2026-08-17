using HomeFix.API.DTOs.SupportMessage;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

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
    public async Task<ActionResult<List<SupportMessageDto>>> GetByTicketId(int supportTicketId)
    {
        var ticket = await _tickets.GetByIdAsync(supportTicketId);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();
        var messages = await _service.GetByTicketIdAsync(supportTicketId);
        return Ok(messages.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<SupportMessageDto>> Create(CreateSupportMessageRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        if (request.SupportTicketId <= 0) return BadRequest(new { message = "A valid support ticket is required." });

        var ticket = await _tickets.GetByIdAsync(request.SupportTicketId);
        if (ticket == null) return NotFound();
        if (!CanAccess(ticket.UserId)) return Forbid();

        var message = request.Message?.Trim();
        var attachmentUrl = request.AttachmentUrl?.Trim();
        if (string.IsNullOrWhiteSpace(message))
            return BadRequest(new { message = "Message is required." });
        if (message.Length > 2000)
            return BadRequest(new { message = "Message is too long." });
        if (attachmentUrl?.Length > 500)
            return BadRequest(new { message = "Attachment URL is too long." });
        if (!string.IsNullOrWhiteSpace(attachmentUrl) &&
            (!Uri.TryCreate(attachmentUrl, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps))
            return BadRequest(new { message = "Attachment URL must be a valid HTTPS URL." });

        var supportMessage = new SupportMessage
        {
            SupportTicketId = request.SupportTicketId,
            SenderId = userId,
            Message = message,
            AttachmentUrl = attachmentUrl,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(supportMessage);
        return Ok(MapToDto(supportMessage));
    }

    private bool CanAccess(int ownerUserId)
    {
        if (User.IsInRole("Admin")) return true;
        return int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)
               && userId == ownerUserId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static SupportMessageDto MapToDto(SupportMessage message) => new()
    {
        Id = message.Id,
        SupportTicketId = message.SupportTicketId,
        SenderId = message.SenderId,
        Message = message.Message,
        AttachmentUrl = message.AttachmentUrl,
        CreatedAt = message.CreatedAt
    };
}