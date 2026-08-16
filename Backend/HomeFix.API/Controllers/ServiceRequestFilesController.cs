using HomeFix.API.DTOs.ServiceRequestFile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ServiceRequestFilesController : ControllerBase
{
    private readonly IServiceRequestFileService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public ServiceRequestFilesController(
        IServiceRequestFileService service,
        IServiceRequestService requests,
        ICustomerProfileService customers,
        ITechnicianProfileService technicians)
    {
        _service = service;
        _requests = requests;
        _customers = customers;
        _technicians = technicians;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceRequestFileDto>> GetById(int id)
    {
        var file = await _service.GetByIdAsync(id);

        if (file == null)
            return NotFound();
        if (!await CanAccessRequestAsync(file.ServiceRequestId)) return Forbid();

        return Ok(MapToDto(file));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<ServiceRequestFileDto>>> GetByRequestId(
        int serviceRequestId)
    {
        if (!await CanAccessRequestAsync(serviceRequestId)) return Forbid();
        var files = await _service.GetByRequestIdAsync(serviceRequestId);

        return Ok(files.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ServiceRequestFileDto>> Create(
        CreateServiceRequestFileRequest request)
    {
        if (!await CanAccessRequestAsync(request.ServiceRequestId)) return Forbid();
        var file = new ServiceRequestFile
        {
            ServiceRequestId = request.ServiceRequestId,
            FileUrl = request.FileUrl,
            FileType = request.FileType,
            UploadedAt = DateTime.UtcNow
        };

        await _service.AddAsync(file);

        return CreatedAtAction(
            nameof(GetById),
            new { id = file.Id },
            MapToDto(file));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var file = await _service.GetByIdAsync(id);

        if (file == null)
            return NotFound();
        if (!await CanAccessRequestAsync(file.ServiceRequestId)) return Forbid();

        await _service.DeleteAsync(file);

        return NoContent();
    }

    private async Task<bool> CanAccessRequestAsync(int serviceRequestId)
    {
        if (User.IsInRole("Admin")) return true;
        var request = await _requests.GetByIdAsync(serviceRequestId);
        if (request == null || !TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && customer.Id == request.CustomerId;
        }
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && request.Booking?.TechnicianId == technician.Id;
        }
        return false;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static ServiceRequestFileDto MapToDto(
        ServiceRequestFile file)
    {
        return new ServiceRequestFileDto
        {
            Id = file.Id,
            ServiceRequestId = file.ServiceRequestId,
            FileUrl = file.FileUrl,
            FileType = file.FileType,
            UploadedAt = file.UploadedAt
        };
    }
}