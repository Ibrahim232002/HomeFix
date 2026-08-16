using HomeFix.API.DTOs.Notification;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _service;

    public NotificationsController(INotificationService service)
    {
        _service = service;
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<List<NotificationDto>>>
        GetByUserId(int userId)
    {
        var notifications =
            await _service.GetByUserIdAsync(userId);

        return Ok(notifications.Select(MapToDto).ToList());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<NotificationDto>> GetById(int id)
    {
        var notification = await _service.GetByIdAsync(id);

        if (notification == null)
            return NotFound();

        return Ok(MapToDto(notification));
    }

    [HttpPost]
    public async Task<ActionResult<NotificationDto>> Create(
        CreateNotificationRequest request)
    {
        var notification = new Notification
        {
            UserId = request.UserId,
            Title = request.Title,
            Message = request.Message,
            Type = request.Type,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(notification);

        return CreatedAtAction(
            nameof(GetById),
            new { id = notification.Id },
            MapToDto(notification));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<NotificationDto>> Update(
        int id,
        UpdateNotificationRequest request)
    {
        var notification = await _service.GetByIdAsync(id);

        if (notification == null)
            return NotFound();

        notification.IsRead = request.IsRead;

        await _service.UpdateAsync(notification);

        return Ok(MapToDto(notification));
    }

    private static NotificationDto MapToDto(
        Notification notification)
    {
        return new NotificationDto
        {
            Id = notification.Id,
            UserId = notification.UserId,
            Title = notification.Title,
            Message = notification.Message,
            IsRead = notification.IsRead,
            CreatedAt = notification.CreatedAt,
            Type = notification.Type
        };
    }
}