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

        var result = services.Select(s => new ServiceDto
        {
            Id = s.Id,
            Name = s.Name,
            Description = s.Description,
            IsActive = s.IsActive
        }).ToList();

        return Ok(result);
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceDto>> GetById(int id)
    {
        var service = await _serviceService.GetServiceByIdAsync(id);

        if (service == null)
            return NotFound();

        var result = new ServiceDto
        {
            Id = service.Id,
            Name = service.Name,
            Description = service.Description,
            IsActive = service.IsActive
        };

        return Ok(result);
    }

    [AllowAnonymous]
    [HttpGet("category/{categoryId:int}")]
    public async Task<ActionResult<List<ServiceDto>>> GetByCategory(int categoryId)
    {
        var services = await _serviceService.GetActiveServicesByCategoryAsync(categoryId);

        return Ok(services.Select(s => new ServiceDto
        {
            Id = s.Id,
            Name = s.Name,
            Description = s.Description,
            IsActive = s.IsActive
        }).ToList());
    }
}