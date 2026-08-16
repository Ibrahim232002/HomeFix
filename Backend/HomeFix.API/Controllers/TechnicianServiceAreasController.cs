using HomeFix.API.DTOs.TechnicianServiceArea;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TechnicianServiceAreasController : ControllerBase
{
    private readonly ITechnicianServiceAreaService _service;

    [AllowAnonymous]
    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianServiceAreaDto>>>
        GetByTechnicianId(int technicianId)
    {
        var areas =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(areas.Select(MapToDto).ToList());
    }

    [AllowAnonymous]
    [HttpGet("city/{cityId:int}")]
    public async Task<ActionResult<List<TechnicianServiceAreaDto>>>
        GetByCityId(int cityId)
    {
        var areas =
            await _service.GetByCityIdAsync(cityId);

        return Ok(areas.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Technician,Admin")]
    [HttpPost]
    public async Task<ActionResult<TechnicianServiceAreaDto>> Create(
        CreateTechnicianServiceAreaRequest request)
    {
        if (!User.IsInRole("Admin"))
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || technician.Id != request.TechnicianId) return Forbid();
        }

        var area = new TechnicianServiceArea
        {
            TechnicianId = request.TechnicianId,
            CityId = request.CityId,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(area);

        return Ok(MapToDto(area));
    }

    [Authorize(Roles = "Technician,Admin")]
    [HttpDelete("{technicianId:int}/{cityId:int}")]
    public async Task<IActionResult> Delete(
        int technicianId,
        int cityId)
    {
        if (!User.IsInRole("Admin"))
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            if (technician == null || technician.Id != technicianId) return Forbid();
        }
        var areas =
            await _service.GetByTechnicianIdAsync(technicianId);

        var area = areas.FirstOrDefault(a => a.CityId == cityId);

        if (area == null)
            return NotFound();

        await _service.DeleteAsync(area);

        return NoContent();
    }

    private readonly ITechnicianProfileService _technicianProfiles;

    public TechnicianServiceAreasController(
        ITechnicianServiceAreaService service,
        ITechnicianProfileService technicianProfiles)
    {
        _service = service;
        _technicianProfiles = technicianProfiles;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static TechnicianServiceAreaDto MapToDto(
        TechnicianServiceArea area)
    {
        return new TechnicianServiceAreaDto
        {
            TechnicianId = area.TechnicianId,
            CityId = area.CityId,
            CreatedAt = area.CreatedAt
        };
    }
}