using HomeFix.API.DTOs.CustomerProfile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CustomerProfilesController : ControllerBase
{
    private readonly ICustomerProfileService _customerProfileService;

    public CustomerProfilesController(
        ICustomerProfileService customerProfileService)
    {
        _customerProfileService = customerProfileService;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<CustomerProfileDto>> GetById(int id)
    {
        var profile = await _customerProfileService.GetByIdAsync(id);

        if (profile == null)
            return NotFound();
        if (!User.IsInRole("Admin") && !IsCurrentUser(profile.UserId)) return Forbid();

        return Ok(MapToDto(profile));
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<CustomerProfileDto>> GetByUserId(int userId)
    {
        var profile = await _customerProfileService.GetByUserIdAsync(userId);

        if (profile == null)
            return NotFound();
        if (!User.IsInRole("Admin") && !IsCurrentUser(profile.UserId)) return Forbid();

        return Ok(MapToDto(profile));
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<CustomerProfileDto>> Create(
        CreateCustomerProfileRequest request)
    {
        var existingProfile =
            await _customerProfileService.GetByUserIdAsync(request.UserId);

        if (existingProfile != null)
            return Conflict(new
            {
                message = "Customer profile already exists."
            });

        var profile = new CustomerProfile
        {
            UserId = request.UserId,
            ProfileImageUrl = request.ProfileImageUrl,
            CreatedAt = DateTime.UtcNow
        };

        await _customerProfileService.AddAsync(profile);

        return CreatedAtAction(
            nameof(GetById),
            new { id = profile.Id },
            MapToDto(profile));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Customer,Admin")]
    public async Task<ActionResult<CustomerProfileDto>> Update(
        int id,
        UpdateCustomerProfileRequest request)
    {
        var profile = await _customerProfileService.GetByIdAsync(id);

        if (profile == null) return NotFound();
        if (!User.IsInRole("Admin"))
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId) || profile.UserId != userId) return Forbid();
        }
        profile.ProfileImageUrl = request.ProfileImageUrl;

        await _customerProfileService.UpdateAsync(profile);

        return Ok(MapToDto(profile));
    }

    private bool IsCurrentUser(int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var currentUserId)
           && currentUserId == userId;

    private static CustomerProfileDto MapToDto(CustomerProfile profile)
    {
        return new CustomerProfileDto
        {
            Id = profile.Id,
            UserId = profile.UserId,
            ProfileImageUrl = profile.ProfileImageUrl,
            CreatedAt = profile.CreatedAt
        };
    }
}