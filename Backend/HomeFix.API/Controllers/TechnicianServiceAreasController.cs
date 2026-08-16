using HomeFix.API.DTOs.TechnicianServiceArea;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TechnicianServiceAreasController : ControllerBase
{
    private readonly ITechnicianServiceAreaService _service;

    public TechnicianServiceAreasController(
        ITechnicianServiceAreaService service)
    {
        _service = service;
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianServiceAreaDto>>>
        GetByTechnicianId(int technicianId)
    {
        var areas =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(areas.Select(MapToDto).ToList());
    }

    [HttpGet("city/{cityId:int}")]
    public async Task<ActionResult<List<TechnicianServiceAreaDto>>>
        GetByCityId(int cityId)
    {
        var areas =
            await _service.GetByCityIdAsync(cityId);

        return Ok(areas.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<TechnicianServiceAreaDto>> Create(
        CreateTechnicianServiceAreaRequest request)
    {
        var area = new TechnicianServiceArea
        {
            TechnicianId = request.TechnicianId,
            CityId = request.CityId,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(area);

        return Ok(MapToDto(area));
    }

    [HttpDelete("{technicianId:int}/{cityId:int}")]
    public async Task<IActionResult> Delete(
        int technicianId,
        int cityId)
    {
        var areas =
            await _service.GetByTechnicianIdAsync(technicianId);

        var area = areas.FirstOrDefault(a => a.CityId == cityId);

        if (area == null)
            return NotFound();

        await _service.DeleteAsync(area);

        return NoContent();
    }

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