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

    public TechnicianProfilesController(ITechnicianProfileService service)
    {
        _service = service;
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> GetById(int id)
    {
        var technician = await _service.GetByIdAsync(id);
        if (technician == null) return NotFound();
        return Ok(MapToDto(technician, CanViewPreciseLocation(technician)));
    }

    [AllowAnonymous]
    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> GetByUserId(int userId)
    {
        var technician = await _service.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        return Ok(MapToDto(technician, CanViewPreciseLocation(technician)));
    }

    [AllowAnonymous]
    [HttpGet("active")]
    public async Task<ActionResult<List<TechnicianProfileDto>>> GetActiveTechnicians()
    {
        var technicians = await _service.GetActiveTechniciansAsync();
        return Ok(technicians.Select(technician => MapToDto(technician, includePreciseLocation: false)).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TechnicianProfileDto>> Create(CreateTechnicianProfileRequest request)
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

        return CreatedAtAction(nameof(GetById), new { id = technician.Id }, MapToDto(technician, includePreciseLocation: true));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Technician,Admin")]
    public async Task<ActionResult<TechnicianProfileDto>> Update(
        int id,
        UpdateTechnicianProfileRequest request)
    {
        var technician = await _service.GetByIdAsync(id);
        if (technician == null) return NotFound();

        if (!User.IsInRole("Admin"))
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId) || technician.UserId != userId)
                return Forbid();
        }

        var locationWasRequested = request.CurrentGovernorateId.HasValue || request.CurrentCityId.HasValue;
        if (locationWasRequested)
        {
            var locationError = await _service.ValidateCurrentLocationAsync(
                request.CurrentGovernorateId,
                request.CurrentCityId);
            if (locationError != null)
                return BadRequest(new { message = locationError });

            technician.CurrentGovernorateId = request.CurrentGovernorateId;
            technician.CurrentCityId = request.CurrentCityId;
        }

        if (request.CurrentLatitude.HasValue)
            technician.CurrentLatitude = request.CurrentLatitude;
        if (request.CurrentLongitude.HasValue)
            technician.CurrentLongitude = request.CurrentLongitude;
        if (request.Bio is not null)
            technician.Bio = request.Bio;
        if (request.ProfileImageUrl is not null)
            technician.ProfileImageUrl = request.ProfileImageUrl;
        if (request.YearsOfExperience.HasValue)
            technician.YearsOfExperience = request.YearsOfExperience;
        if (request.IsAvailable.HasValue)
            technician.IsAvailable = request.IsAvailable.Value;
        if (User.IsInRole("Admin") && request.IsVerified.HasValue)
            technician.IsVerified = request.IsVerified.Value;

        var specializationWasRequested = request.CategoryId.HasValue || request.ServiceIds is not null;
        if (specializationWasRequested)
        {
            var specializationError = await _service.ApplySpecializationAsync(
                technician,
                request.CategoryId,
                request.ServiceIds);
            if (specializationError != null)
                return BadRequest(new { message = specializationError });
        }

        await _service.UpdateAsync(technician);
        return Ok(MapToDto(technician, includePreciseLocation: true));
    }

    private bool CanViewPreciseLocation(TechnicianProfile technician)
    {
        if (User.IsInRole("Admin")) return true;
        if (!User.IsInRole("Technician")) return false;
        return int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)
            && technician.UserId == userId;
    }

    private static TechnicianProfileDto MapToDto(TechnicianProfile technician, bool includePreciseLocation)
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
            CurrentLatitude = includePreciseLocation ? technician.CurrentLatitude : null,
            CurrentLongitude = includePreciseLocation ? technician.CurrentLongitude : null,
            CurrentGovernorateId = technician.CurrentGovernorateId,
            CurrentCityId = technician.CurrentCityId
        };
    }
}
