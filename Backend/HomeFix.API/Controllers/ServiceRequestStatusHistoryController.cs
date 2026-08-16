using HomeFix.API.DTOs.ServiceRequestStatusHistory;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServiceRequestStatusHistoryController : ControllerBase
{
    private readonly IServiceRequestStatusHistoryService _service;

    public ServiceRequestStatusHistoryController(
        IServiceRequestStatusHistoryService service)
    {
        _service = service;
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<ServiceRequestStatusHistoryDto>>>
        GetByRequestId(int serviceRequestId)
    {
        var history =
            await _service.GetByRequestIdAsync(serviceRequestId);

        return Ok(history.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ServiceRequestStatusHistoryDto>> Create(
        CreateServiceRequestStatusHistoryRequest request)
    {
        var history = new ServiceRequestStatusHistory
        {
            ServiceRequestId = request.ServiceRequestId,
            OldStatus = request.OldStatus,
            NewStatus = request.NewStatus,
            ChangedByUserId = request.ChangedByUserId,
            ChangedAt = DateTime.UtcNow
        };

        await _service.AddAsync(history);

        return Ok(MapToDto(history));
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