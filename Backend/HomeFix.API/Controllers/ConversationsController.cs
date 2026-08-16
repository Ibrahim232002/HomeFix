using HomeFix.API.DTOs.Conversation;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ConversationsController : ControllerBase
{
    private readonly IConversationService _service;

    public ConversationsController(IConversationService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ConversationDto>> GetById(int id)
    {
        var conversation = await _service.GetByIdAsync(id);

        if (conversation == null)
            return NotFound();

        return Ok(MapToDto(conversation));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<ConversationDto>> GetByRequestId(
        int serviceRequestId)
    {
        var conversation =
            await _service.GetByRequestIdAsync(serviceRequestId);

        if (conversation == null)
            return NotFound();

        return Ok(MapToDto(conversation));
    }

    [HttpGet("customer/{customerId:int}")]
    public async Task<ActionResult<List<ConversationDto>>>
        GetByCustomerId(int customerId)
    {
        var conversations =
            await _service.GetByCustomerIdAsync(customerId);

        return Ok(conversations.Select(MapToDto).ToList());
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<ConversationDto>>>
        GetByTechnicianId(int technicianId)
    {
        var conversations =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(conversations.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ConversationDto>> Create(
        CreateConversationRequest request)
    {
        var conversation = new Conversation
        {
            ServiceRequestId = request.ServiceRequestId,
            CustomerId = request.CustomerId,
            TechnicianId = request.TechnicianId,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(conversation);

        return CreatedAtAction(
            nameof(GetById),
            new { id = conversation.Id },
            MapToDto(conversation));
    }

    private static ConversationDto MapToDto(
        Conversation conversation)
    {
        return new ConversationDto
        {
            Id = conversation.Id,
            ServiceRequestId = conversation.ServiceRequestId,
            CustomerId = conversation.CustomerId,
            TechnicianId = conversation.TechnicianId,
            CreatedAt = conversation.CreatedAt
        };
    }
}