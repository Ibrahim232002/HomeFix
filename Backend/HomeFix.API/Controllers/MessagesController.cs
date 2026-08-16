using HomeFix.API.DTOs.Message;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MessagesController : ControllerBase
{
    private readonly IMessageService _service;

    public MessagesController(IMessageService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<MessageDto>> GetById(int id)
    {
        var message = await _service.GetByIdAsync(id);

        if (message == null)
            return NotFound();

        return Ok(MapToDto(message));
    }

    [HttpGet("conversation/{conversationId:int}")]
    public async Task<ActionResult<List<MessageDto>>>
        GetByConversationId(int conversationId)
    {
        var messages =
            await _service.GetByConversationIdAsync(conversationId);

        return Ok(messages.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<MessageDto>> Create(
        CreateMessageRequest request)
    {
        var message = new Message
        {
            ConversationId = request.ConversationId,
            SenderId = request.SenderId,
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