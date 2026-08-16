using System.Security.Claims;
using HomeFix.API.DTOs.Notification;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _service;

    public NotificationsController(INotificationService service) => _service = service;

    [HttpGet("me")]
    public async Task<ActionResult<List<NotificationDto>>> GetMine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var notifications = await _service.GetByUserIdAsync(userId);
        return Ok(notifications.Select(MapToDto).ToList());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<NotificationDto>> GetById(int id)
    {
        var notification = await _service.GetByIdAsync(id);
        if (notification is null) return NotFound();
        if (!TryGetUserId(out var userId)) return Unauthorized();
        if (notification.UserId != userId && !User.IsInRole("Admin")) return Forbid();
        return Ok(MapToDto(notification));
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<NotificationDto>> Create(CreateNotificationRequest request)
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
        return CreatedAtAction(nameof(GetById), new { id = notification.Id }, MapToDto(notification));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<NotificationDto>> MarkRead(int id, UpdateNotificationRequest request)
    {
        var notification = await _service.GetByIdAsync(id);
        if (notification is null) return NotFound();
        if (!TryGetUserId(out var userId)) return Unauthorized();
        if (notification.UserId != userId && !User.IsInRole("Admin")) return Forbid();

        notification.IsRead = request.IsRead;
        await _service.UpdateAsync(notification);
        return Ok(MapToDto(notification));
    }

    private static NotificationDto MapToDto(Notification notification) => new()
    {
        Id = notification.Id,
        UserId = notification.UserId,
        Title = notification.Title,
        Message = notification.Message,
        IsRead = notification.IsRead,
        CreatedAt = notification.CreatedAt,
        Type = notification.Type,
        ReferenceId = notification.ReferenceId
    };

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
