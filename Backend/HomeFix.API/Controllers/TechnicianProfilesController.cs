using HomeFix.API.DTOs.TechnicianProfile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TechnicianProfilesController : ControllerBase
{
    private readonly ITechnicianProfileService _service;

    public TechnicianProfilesController(
        ITechnicianProfileService service)
    {
        _service = service;
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> GetById(int id)
    {
        var technician = await _service.GetByIdAsync(id);

        if (technician == null)
            return NotFound();

        return Ok(MapToDto(technician));
    }

    [AllowAnonymous]
    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> GetByUserId(int userId)
    {
        var technician = await _service.GetByUserIdAsync(userId);

        if (technician == null)
            return NotFound();

        return Ok(MapToDto(technician));
    }

    [AllowAnonymous]
    [HttpGet("active")]
    public async Task<ActionResult<List<TechnicianProfileDto>>> GetActiveTechnicians()
    {
        var technicians = await _service.GetActiveTechniciansAsync();
        return Ok(technicians.Select(MapToDto).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TechnicianProfileDto>> Create(
        CreateTechnicianProfileRequest request)
    {
        var validationError = await _service.ValidateCurrentLocationAsync(
            request.CurrentGovernorateId,
            request.CurrentCityId);
        if (validationError != null)
            return BadRequest(new { message = validationError });

        var technician = new TechnicianProfile
        {
            UserId = request.UserId,
            CategoryId = request.CategoryId,
            Bio = request.Bio,
            ProfileImageUrl = request.ProfileImageUrl,
            YearsOfExperience = request.YearsOfExperience,
            IsVerified = request.IsVerified,
            IsAvailable = request.IsAvailable,
            AverageRating = 0,
            TotalJobs = 0,
            CreatedAt = DateTime.UtcNow,
            CurrentLatitude = request.CurrentLatitude,
            CurrentLongitude = request.CurrentLongitude,
            CurrentGovernorateId = request.CurrentGovernorateId,
            CurrentCityId = request.CurrentCityId
        };

        validationError = await _service.ApplySpecializationAsync(
            technician,
            request.CategoryId,
            Array.Empty<int>());
        if (validationError != null)
            return BadRequest(new { message = validationError });

        await _service.AddAsync(technician);

        return CreatedAtAction(
            nameof(GetById),
            new { id = technician.Id },
            MapToDto(technician));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Technician,Admin")]
    public async Task<ActionResult<TechnicianProfileDto>> Update(
        int id,
        UpdateTechnicianProfileRequest request)
    {
        var technician = await _service.GetByIdAsync(id);

        if (technician == null)
            return NotFound();

        if (!User.IsInRole("Admin"))
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId) || technician.UserId != userId)
                return Forbid();
        }

        var validationError = await _service.ValidateCurrentLocationAsync(
            request.CurrentGovernorateId,
            request.CurrentCityId);
        if (validationError != null)
            return BadRequest(new { message = validationError });

        var specializationWasRequested = request.CategoryId.HasValue || request.ServiceIds is not null;
        if (specializationWasRequested)
        {
            validationError = await _service.ApplySpecializationAsync(
                technician,
                request.CategoryId,
                request.ServiceIds);
            if (validationError != null)
                return BadRequest(new { message = validationError });
        }

        technician.Bio = request.Bio;
        technician.ProfileImageUrl = request.ProfileImageUrl;
        technician.YearsOfExperience = request.YearsOfExperience;
        technician.CurrentLatitude = request.CurrentLatitude;
        technician.CurrentLongitude = request.CurrentLongitude;
        technician.CurrentGovernorateId = request.CurrentGovernorateId;
        technician.CurrentCityId = request.CurrentCityId;
        technician.IsAvailable = request.IsAvailable;

        if (User.IsInRole("Admin"))
            technician.IsVerified = request.IsVerified;

        await _service.UpdateAsync(technician);

        return Ok(MapToDto(technician));
    }

    private static TechnicianProfileDto MapToDto(TechnicianProfile technician)
    {
        return new TechnicianProfileDto
        {
            Id = technician.Id,
            UserId = technician.UserId,
            CategoryId = technician.CategoryId,
            CategoryName = technician.Category?.Name ?? string.Empty,
            ServiceIds = technician.Services.Select(s => s.Id).OrderBy(id => id).ToList(),
            Bio = technician.Bio,
            ProfileImageUrl = technician.ProfileImageUrl,
            YearsOfExperience = technician.YearsOfExperience,
            IsVerified = technician.IsVerified,
            IsAvailable = technician.IsAvailable,
            AverageRating = technician.AverageRating,
            TotalJobs = technician.TotalJobs,
            CreatedAt = technician.CreatedAt,
            CurrentLatitude = technician.CurrentLatitude,
            CurrentLongitude = technician.CurrentLongitude,
            CurrentGovernorateId = technician.CurrentGovernorateId,
            CurrentCityId = technician.CurrentCityId
        };
    }
}
