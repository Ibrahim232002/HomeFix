using HomeFix.API.DTOs.CustomerProfile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
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

        return Ok(MapToDto(profile));
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<CustomerProfileDto>> GetByUserId(int userId)
    {
        var profile = await _customerProfileService.GetByUserIdAsync(userId);

        if (profile == null)
            return NotFound();

        return Ok(MapToDto(profile));
    }

    [HttpPost]
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
    public async Task<ActionResult<CustomerProfileDto>> Update(
        int id,
        UpdateCustomerProfileRequest request)
    {
        var profile = await _customerProfileService.GetByIdAsync(id);

        if (profile == null)
            return NotFound();

        profile.ProfileImageUrl = request.ProfileImageUrl;

        await _customerProfileService.UpdateAsync(profile);

        return Ok(MapToDto(profile));
    }

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