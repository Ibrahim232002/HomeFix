using HomeFix.API.DTOs.ServiceRequest;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServiceRequestsController : ControllerBase
{
    private readonly IServiceRequestService _service;

    public ServiceRequestsController(IServiceRequestService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceRequestDto>> GetById(int id)
    {
        var request = await _service.GetByIdAsync(id);

        if (request == null)
            return NotFound();

        return Ok(MapToDto(request));
    }

    [HttpGet("customer/{customerId:int}")]
    public async Task<ActionResult<List<ServiceRequestDto>>> GetByCustomerId(
        int customerId)
    {
        var requests = await _service.GetByCustomerIdAsync(customerId);

        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpGet("status/{status}")]
    public async Task<ActionResult<List<ServiceRequestDto>>> GetByStatus(
        string status)
    {
        var requests = await _service.GetByStatusAsync(status);

        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ServiceRequestDto>> Create(
        CreateServiceRequestRequest request)
    {
        var serviceRequest = new ServiceRequest
        {
            CustomerId = request.CustomerId,
            ServiceId = request.ServiceId,
            AddressId = request.AddressId,
            Description = request.Description,
            PreferredDate = request.PreferredDate,
            PreferredTime = request.PreferredTime,
            Status = request.Status,
            VisitFee = request.VisitFee
        };

        await _service.CreateAsync(serviceRequest);

        return CreatedAtAction(
            nameof(GetById),
            new { id = serviceRequest.Id },
            MapToDto(serviceRequest));
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(
        int id,
        ServiceRequest request)
    {
        if (id != request.Id)
            return BadRequest();

        await _service.UpdateAsync(request);

        return Ok(MapToDto(request));
    }

    private static ServiceRequestDto MapToDto(
        ServiceRequest request)
    {
        return new ServiceRequestDto
        {
            Id = request.Id,
            CustomerId = request.CustomerId,
            ServiceId = request.ServiceId,
            AddressId = request.AddressId,
            Description = request.Description,
            PreferredDate = request.PreferredDate,
            PreferredTime = request.PreferredTime,
            Status = request.Status,
            VisitFee = request.VisitFee,
            CreatedAt = request.CreatedAt,
            UpdatedAt = request.UpdatedAt
        };
    }
}