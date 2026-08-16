using HomeFix.API.DTOs.Governorate;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GovernoratesController : ControllerBase
{
    private readonly IGovernorateService _governorateService;

    public GovernoratesController(
        IGovernorateService governorateService)
    {
        _governorateService = governorateService;
    }

    [HttpGet]
    public async Task<ActionResult<List<GovernorateDto>>> GetAll()
    {
        var governorates =
            await _governorateService.GetAllAsync();

        var result = governorates
            .Select(MapToDto)
            .ToList();

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<GovernorateDto>> GetById(int id)
    {
        var governorate =
            await _governorateService.GetByIdAsync(id);

        if (governorate == null)
            return NotFound();

        return Ok(MapToDto(governorate));
    }

    private static GovernorateDto MapToDto(
        Governorate governorate)
    {
        return new GovernorateDto
        {
            Id = governorate.Id,
            Name = governorate.Name,
            IsActive = governorate.IsActive,
            CreatedAt = governorate.CreatedAt
        };
    }
}