using HomeFix.API.DTOs.TechnicianAvailability;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TechnicianAvailabilitiesController : ControllerBase
{
    private readonly ITechnicianAvailabilityService _service;
    private readonly ITechnicianProfileService _technicianProfiles;

    public TechnicianAvailabilitiesController(
        ITechnicianAvailabilityService service,
        ITechnicianProfileService technicianProfiles)
    {
        _service = service;
        _technicianProfiles = technicianProfiles;
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianAvailabilityDto>> GetById(int id)
    {
        var availability = await _service.GetByIdAsync(id);

        if (availability == null)
            return NotFound();

        return Ok(MapToDto(availability));
    }

    [AllowAnonymous]
    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianAvailabilityDto>>>
        GetByTechnicianId(int technicianId)
    {
        var availability =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(availability.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Technician,Admin")]
    [HttpPost]
    public async Task<ActionResult<TechnicianAvailabilityDto>> Create(
        CreateTechnicianAvailabilityRequest request)
    {
        if (!User.IsInRole("Admin"))
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || technician.Id != request.TechnicianId) return Forbid();
        }
        var availability = new TechnicianAvailability
        {
            TechnicianId = request.TechnicianId,
            DayOfWeek = request.DayOfWeek,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            IsAvailable = request.IsAvailable
        };

        await _service.AddAsync(availability);

        return CreatedAtAction(
            nameof(GetById),
            new { id = availability.Id },
            MapToDto(availability));
    }

    [Authorize(Roles = "Technician,Admin")]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<TechnicianAvailabilityDto>> Update(
        int id,
        UpdateTechnicianAvailabilityRequest request)
    {
        var availability = await _service.GetByIdAsync(id);

        if (availability == null)
            return NotFound();

        if (!User.IsInRole("Admin"))
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || technician.Id != availability.TechnicianId) return Forbid();
        }

        availability.DayOfWeek = request.DayOfWeek;
        availability.StartTime = request.StartTime;
        availability.EndTime = request.EndTime;
        availability.IsAvailable = request.IsAvailable;

        await _service.UpdateAsync(availability);

        return Ok(MapToDto(availability));
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static TechnicianAvailabilityDto MapToDto(
        TechnicianAvailability availability)
    {
        return new TechnicianAvailabilityDto
        {
            Id = availability.Id,
            TechnicianId = availability.TechnicianId,
            DayOfWeek = availability.DayOfWeek,
            StartTime = availability.StartTime,
            EndTime = availability.EndTime,
            IsAvailable = availability.IsAvailable
        };
    }
}