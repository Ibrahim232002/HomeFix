using HomeFix.API.DTOs.City;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CitiesController : ControllerBase
{
    private readonly ICityService _cityService;

    public CitiesController(ICityService cityService)
    {
        _cityService = cityService;
    }

    [HttpGet]
    public async Task<ActionResult<List<CityDto>>> GetAll()
    {
        var cities =
            await _cityService.GetAllAsync();

        var result = cities
            .Select(MapToDto)
            .ToList();

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<CityDto>> GetById(int id)
    {
        var city =
            await _cityService.GetByIdAsync(id);

        if (city == null)
            return NotFound();

        return Ok(MapToDto(city));
    }

    [HttpGet("governorate/{governorateId:int}")]
    public async Task<ActionResult<List<CityDto>>> GetByGovernorateId(
        int governorateId)
    {
        var cities =
            await _cityService.GetByGovernorateIdAsync(governorateId);

        var result = cities
            .Select(MapToDto)
            .ToList();

        return Ok(result);
    }

    private static CityDto MapToDto(City city)
    {
        return new CityDto
        {
            Id = city.Id,
            GovernorateId = city.GovernorateId,
            Name = city.Name,
            IsActive = city.IsActive,
            CreatedAt = city.CreatedAt
        };
    }
}