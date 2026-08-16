using HomeFix.API.DTOs.ServiceRequest;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ServiceRequestsController : ControllerBase
{
    private readonly IServiceRequestService _service;
    private readonly ICustomerProfileService _customerProfiles;
    private readonly ITechnicianProfileService _technicianProfiles;

    public ServiceRequestsController(IServiceRequestService service, ICustomerProfileService customerProfiles, ITechnicianProfileService technicianProfiles)
    {
        _service = service; _customerProfiles = customerProfiles; _technicianProfiles = technicianProfiles;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceRequestDto>> GetById(int id)
    {
        var request = await _service.GetByIdAsync(id);
        if (request == null) return NotFound();
        if (!await CanAccessAsync(request)) return Forbid();
        return Ok(MapToDto(request));
    }

    [HttpGet("mine")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<List<ServiceRequestDto>>> Mine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        if (profile == null) return NotFound();
        var requests = await _service.GetByCustomerIdAsync(profile.Id);
        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpGet("technician-available")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<List<ServiceRequestDto>>> TechnicianAvailable()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicianProfiles.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var requests = await _service.GetPendingForTechnicianAsync(technician.Id);
        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpGet("customer/{customerId:int}")]
    [Authorize(Roles = "Customer,Admin")]
    public async Task<ActionResult<List<ServiceRequestDto>>> GetByCustomerId(int customerId)
    {
        if (!await IsCustomerOrAdminAsync(customerId)) return Forbid();
        var requests = await _service.GetByCustomerIdAsync(customerId);
        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpGet("status/{status}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<ServiceRequestDto>>> GetByStatus(string status)
    {
        var requests = await _service.GetByStatusAsync(status);
        return Ok(requests.Select(MapToDto).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<ServiceRequestDto>> Create(CreateServiceRequestRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        if (profile == null) return NotFound(new { message = "Customer profile not found." });
        if (string.IsNullOrWhiteSpace(request.Description)) return BadRequest(new { message = "Description is required." });

        var serviceRequest = new ServiceRequest
        {
            CustomerId = profile.Id,
            ServiceId = request.ServiceId,
            AddressId = request.AddressId,
            Description = request.Description.Trim(),
            PreferredDate = request.PreferredDate,
            PreferredTime = request.PreferredTime,
            Status = "Open",
            VisitFee = request.VisitFee,
            CreatedAt = DateTime.UtcNow
        };
        await _service.CreateAsync(serviceRequest);
        return CreatedAtAction(nameof(GetById), new { id = serviceRequest.Id }, MapToDto(serviceRequest));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Update(int id, UpdateServiceRequestRequest request)
    {
        var serviceRequest = await _service.GetByIdAsync(id);
        if (serviceRequest == null) return NotFound();
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        if (profile == null || serviceRequest.CustomerId != profile.Id) return Forbid();
        if (serviceRequest.Status is "Accepted" or "Completed" or "Cancelled") return BadRequest(new { message = "This request can no longer be edited." });

        if (request.Description != null) serviceRequest.Description = request.Description.Trim();
        if (request.PreferredDate.HasValue) serviceRequest.PreferredDate = request.PreferredDate;
        if (request.PreferredTime.HasValue) serviceRequest.PreferredTime = request.PreferredTime;
        serviceRequest.UpdatedAt = DateTime.UtcNow;
        await _service.UpdateAsync(serviceRequest);
        return Ok(MapToDto(serviceRequest));
    }

    private async Task<bool> CanAccessAsync(ServiceRequest request)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Customer"))
        {
            var profile = await _customerProfiles.GetByUserIdAsync(userId);
            return profile != null && profile.Id == request.CustomerId;
        }
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            return technician != null && request.Booking?.TechnicianId == technician.Id;
        }
        return false;
    }

    private async Task<bool> IsCustomerOrAdminAsync(int customerId)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        return profile != null && profile.Id == customerId;
    }

    private bool TryGetUserId(out int userId) => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static ServiceRequestDto MapToDto(ServiceRequest request) => new()
    {
        Id = request.Id, CustomerId = request.CustomerId, ServiceId = request.ServiceId, AddressId = request.AddressId,
        Description = request.Description, PreferredDate = request.PreferredDate, PreferredTime = request.PreferredTime,
        Status = request.Status, VisitFee = request.VisitFee, CreatedAt = request.CreatedAt, UpdatedAt = request.UpdatedAt
    };
}
