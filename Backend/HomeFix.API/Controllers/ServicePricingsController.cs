using Microsoft.AspNetCore.Authorization;
﻿using HomeFix.API.DTOs.ServicePricing;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServicePricingsController : ControllerBase
{
    private readonly IServicePricingService _service;

    public ServicePricingsController(IServicePricingService service)
    {
        _service = service;
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<ActionResult<ServicePricingDto>> Get(
        [FromQuery] int serviceId,
        [FromQuery] int cityId)
    {
        var pricing = await _service.GetAsync(serviceId, cityId);

        if (pricing == null)
            return NotFound();

        return Ok(new ServicePricingDto
        {
            Id = pricing.Id,
            ServiceId = pricing.ServiceId,
            CityId = pricing.CityId,
            VisitFee = pricing.VisitFee,
            MinimumPrice = pricing.MinimumPrice,
            MaximumPrice = pricing.MaximumPrice,
            InspectionFee = pricing.InspectionFee,
            IsActive = pricing.IsActive,
            CreatedAt = pricing.CreatedAt
        });
    }

    [AllowAnonymous]
    [HttpGet("service/{serviceId:int}")]
    public async Task<ActionResult<List<ServicePricingDto>>> GetByServiceId(
        int serviceId)
    {
        var prices = await _service.GetByServiceIdAsync(serviceId);

        var result = prices.Select(p => new ServicePricingDto
        {
            Id = p.Id,
            ServiceId = p.ServiceId,
            CityId = p.CityId,
            VisitFee = p.VisitFee,
            MinimumPrice = p.MinimumPrice,
            MaximumPrice = p.MaximumPrice,
            InspectionFee = p.InspectionFee,
            IsActive = p.IsActive,
            CreatedAt = p.CreatedAt
        }).ToList();

        return Ok(result);
    }
}