using HomeFix.API.DTOs.ServiceRequestStatusHistory;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ServiceRequestStatusHistoryController : ControllerBase
{
    private readonly IServiceRequestStatusHistoryService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public ServiceRequestStatusHistoryController(
        IServiceRequestStatusHistoryService service,
        IServiceRequestService requests,
        ICustomerProfileService customers,
        ITechnicianProfileService technicians)
    {
        _service = service;
        _requests = requests;
        _customers = customers;
        _technicians = technicians;
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<ServiceRequestStatusHistoryDto>>>
        GetByRequestId(int serviceRequestId)
    {
        if (!await CanAccessRequestAsync(serviceRequestId)) return Forbid();
        var history =
            await _service.GetByRequestIdAsync(serviceRequestId);

        return Ok(history.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Admin") ]
    [HttpPost]
    public async Task<ActionResult<ServiceRequestStatusHistoryDto>> Create(
        CreateServiceRequestStatusHistoryRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var history = new ServiceRequestStatusHistory
        {
            ServiceRequestId = request.ServiceRequestId,
            OldStatus = request.OldStatus,
            NewStatus = request.NewStatus,
            ChangedByUserId = userId,
            ChangedAt = DateTime.UtcNow
        };

        await _service.AddAsync(history);

        return Ok(MapToDto(history));
    }

    private async Task<bool> CanAccessRequestAsync(int serviceRequestId)
    {
        if (User.IsInRole("Admin")) return true;
        var request = await _requests.GetByIdAsync(serviceRequestId);
        if (request == null || !int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return false;
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

    private static ServiceRequestStatusHistoryDto MapToDto(
        ServiceRequestStatusHistory history)
    {
        return new ServiceRequestStatusHistoryDto
        {
            Id = history.Id,
            ServiceRequestId = history.ServiceRequestId,
            OldStatus = history.OldStatus,
            NewStatus = history.NewStatus,
            ChangedByUserId = history.ChangedByUserId,
            ChangedAt = history.ChangedAt
        };
    }
}