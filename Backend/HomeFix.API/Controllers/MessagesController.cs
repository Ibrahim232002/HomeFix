using HomeFix.API.DTOs.Message;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MessagesController : ControllerBase
{
    private readonly IMessageService _service;
    private readonly IConversationService _conversations;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public MessagesController(
        IMessageService service,
        IConversationService conversations,
        ICustomerProfileService customers,
        ITechnicianProfileService technicians)
    {
        _service = service;
        _conversations = conversations;
        _customers = customers;
        _technicians = technicians;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<MessageDto>> GetById(int id)
    {
        var message = await _service.GetByIdAsync(id);

        if (message == null)
            return NotFound();
        var conversation = await _conversations.GetByIdAsync(message.ConversationId);
        if (conversation == null || !await CanAccessAsync(conversation)) return Forbid();

        return Ok(MapToDto(message));
    }

    [HttpGet("conversation/{conversationId:int}")]
    public async Task<ActionResult<List<MessageDto>>>
        GetByConversationId(int conversationId)
    {
        var conversation = await _conversations.GetByIdAsync(conversationId);
        if (conversation == null) return NotFound();
        if (!await CanAccessAsync(conversation)) return Forbid();
        var messages =
            await _service.GetByConversationIdAsync(conversationId);

        return Ok(messages.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<MessageDto>> Create(
        CreateMessageRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var conversation = await _conversations.GetByIdAsync(request.ConversationId);
        if (conversation == null) return NotFound();
        if (!await CanAccessAsync(conversation)) return Forbid();

        var message = new Message
        {
            ConversationId = request.ConversationId,
            SenderId = userId,
            MessageText = request.MessageText,
            AttachmentUrl = request.AttachmentUrl,
            AttachmentType = request.AttachmentType,
            IsRead = false,
            SentAt = DateTime.UtcNow
        };

        await _service.AddAsync(message);

        return CreatedAtAction(
            nameof(GetById),
            new { id = message.Id },
            MapToDto(message));
    }

    private async Task<bool> CanAccessAsync(HomeFix.DAL.Entities.Conversation conversation)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && customer.Id == conversation.CustomerId;
        }
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && technician.Id == conversation.TechnicianId;
        }
        return false;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static MessageDto MapToDto(Message message)
    {
        return new MessageDto
        {
            Id = message.Id,
            ConversationId = message.ConversationId,
            SenderId = message.SenderId,
            MessageText = message.MessageText,
            AttachmentUrl = message.AttachmentUrl,
            AttachmentType = message.AttachmentType,
            IsRead = message.IsRead,
            SentAt = message.SentAt
        };
    }
}