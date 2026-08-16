using HomeFix.API.DTOs.TechnicianAvailability;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TechnicianAvailabilitiesController : ControllerBase
{
    private readonly ITechnicianAvailabilityService _service;

    public TechnicianAvailabilitiesController(
        ITechnicianAvailabilityService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianAvailabilityDto>> GetById(int id)
    {
        var availability = await _service.GetByIdAsync(id);

        if (availability == null)
            return NotFound();

        return Ok(MapToDto(availability));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianAvailabilityDto>>>
        GetByTechnicianId(int technicianId)
    {
        var availability =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(availability.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<TechnicianAvailabilityDto>> Create(
        CreateTechnicianAvailabilityRequest request)
    {
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

    [HttpPut("{id:int}")]
    public async Task<ActionResult<TechnicianAvailabilityDto>> Update(
        int id,
        UpdateTechnicianAvailabilityRequest request)
    {
        var availability = await _service.GetByIdAsync(id);

        if (availability == null)
            return NotFound();

        availability.DayOfWeek = request.DayOfWeek;
        availability.StartTime = request.StartTime;
        availability.EndTime = request.EndTime;
        availability.IsAvailable = request.IsAvailable;

        await _service.UpdateAsync(availability);

        return Ok(MapToDto(availability));
    }

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