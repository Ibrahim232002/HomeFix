using Microsoft.AspNetCore.Authorization;
﻿using HomeFix.API.DTOs.Services;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServicesController : ControllerBase
{
    private readonly IServiceService _serviceService;

    public ServicesController(IServiceService serviceService)
    {
        _serviceService = serviceService;
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<ActionResult<List<ServiceDto>>> GetAll()
    {
        var services = await _serviceService.GetAllServicesAsync();

        return Ok(services.Select(MapToDto).ToList());
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceDto>> GetById(int id)
    {
        var service = await _serviceService.GetActiveServiceByIdAsync(id);

        if (service == null)
            return NotFound();

        return Ok(MapToDto(service));
    }

    [AllowAnonymous]
    [HttpGet("category/{categoryId:int}")]
    public async Task<ActionResult<List<ServiceDto>>> GetByCategory(int categoryId)
    {
        var services = await _serviceService.GetActiveServicesByCategoryAsync(categoryId);
        return Ok(services.Select(MapToDto).ToList());
    }

    private static ServiceDto MapToDto(HomeFix.DAL.Entities.Service service)
        => new()
        {
            Id = service.Id,
            Name = service.Name,
            Description = service.Description,
            CategoryId = service.CategoryId,
            PricingMode = service.PricingMode,
            IsActive = service.IsActive
        };
}
