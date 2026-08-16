using System.Security.Claims;
using HomeFix.API.DTOs.UserDevice;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class UserDevicesController : ControllerBase
{
    private readonly IUserDeviceService _service;

    public UserDevicesController(IUserDeviceService service)
    {
        _service = service;
    }

    [HttpGet("me")]
    public async Task<ActionResult<List<object>>> GetMine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var devices = await _service.GetActiveAsync(userId);
        return Ok(devices.Select(Map).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<object>> Register(RegisterUserDeviceRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        try
        {
            var device = await _service.RegisterOrUpdateAsync(userId, request.DeviceToken, request.Platform);
            return Ok(Map(device));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete]
    public async Task<IActionResult> Deactivate([FromQuery] string deviceToken)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        if (string.IsNullOrWhiteSpace(deviceToken)) return BadRequest(new { message = "deviceToken is required." });
        return await _service.DeactivateAsync(userId, deviceToken)
            ? NoContent()
            : NotFound();
    }

    private static object Map(UserDevice d) => new
    {
        d.Id,
        d.DeviceToken,
        d.Platform,
        d.IsActive,
        d.CreatedAt,
        d.LastSeenAt
    };

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
