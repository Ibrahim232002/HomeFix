using HomeFix.API.DTOs.SupportMessage;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SupportMessagesController : ControllerBase
{
    private readonly ISupportMessageService _service;

    public SupportMessagesController(ISupportMessageService service)
    {
        _service = service;
    }

    [HttpGet("ticket/{supportTicketId:int}")]
    public async Task<ActionResult<List<SupportMessageDto>>>
        GetByTicketId(int supportTicketId)
    {
        var messages = await _service.GetByTicketIdAsync(supportTicketId);

        return Ok(messages.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<SupportMessageDto>> Create(
        CreateSupportMessageRequest request)
    {
        var message = new SupportMessage
        {
            SupportTicketId = request.SupportTicketId,
            SenderId = request.SenderId,
            Message = request.Message,
            AttachmentUrl = request.AttachmentUrl,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(message);

        return Ok(MapToDto(message));
    }

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