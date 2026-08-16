using HomeFix.API.DTOs.TechnicianProfile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TechnicianProfilesController : ControllerBase
{
    private readonly ITechnicianProfileService _service;

    public TechnicianProfilesController(
        ITechnicianProfileService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> GetById(int id)
    {
        var technician = await _service.GetByIdAsync(id);

        if (technician == null)
            return NotFound();

        return Ok(MapToDto(technician));
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<TechnicianProfileDto>>
        GetByUserId(int userId)
    {
        var technician = await _service.GetByUserIdAsync(userId);

        if (technician == null)
            return NotFound();

        return Ok(MapToDto(technician));
    }

    [HttpGet("active")]
    public async Task<ActionResult<List<TechnicianProfileDto>>>
        GetActiveTechnicians()
    {
        var technicians = await _service.GetActiveTechniciansAsync();

        return Ok(technicians.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<TechnicianProfileDto>> Create(
        CreateTechnicianProfileRequest request)
    {
        var technician = new TechnicianProfile
        {
            UserId = request.UserId,
            Bio = request.Bio,
            ProfileImageUrl = request.ProfileImageUrl,
            YearsOfExperience = request.YearsOfExperience,
            IsVerified = request.IsVerified,
            IsAvailable = request.IsAvailable,
            AverageRating = 0,
            TotalJobs = 0,
            CreatedAt = DateTime.UtcNow,
            CurrentLatitude = request.CurrentLatitude,
            CurrentLongitude = request.CurrentLongitude
        };

        await _service.AddAsync(technician);

        return CreatedAtAction(
            nameof(GetById),
            new { id = technician.Id },
            MapToDto(technician));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<TechnicianProfileDto>> Update(
        int id,
        UpdateTechnicianProfileRequest request)
    {
        var technician = await _service.GetByIdAsync(id);

        if (technician == null)
            return NotFound();

        technician.Bio = request.Bio;
        technician.ProfileImageUrl = request.ProfileImageUrl;
        technician.YearsOfExperience = request.YearsOfExperience;
        technician.IsVerified = request.IsVerified;
        technician.IsAvailable = request.IsAvailable;
        technician.CurrentLatitude = request.CurrentLatitude;
        technician.CurrentLongitude = request.CurrentLongitude;

        await _service.UpdateAsync(technician);

        return Ok(MapToDto(technician));
    }

    private static TechnicianProfileDto MapToDto(
        TechnicianProfile technician)
    {
        return new TechnicianProfileDto
        {
            Id = technician.Id,
            UserId = technician.UserId,
            Bio = technician.Bio,
            ProfileImageUrl = technician.ProfileImageUrl,
            YearsOfExperience = technician.YearsOfExperience,
            IsVerified = technician.IsVerified,
            IsAvailable = technician.IsAvailable,
            AverageRating = technician.AverageRating,
            TotalJobs = technician.TotalJobs,
            CreatedAt = technician.CreatedAt,
            CurrentLatitude = technician.CurrentLatitude,
            CurrentLongitude = technician.CurrentLongitude
        };
    }
}