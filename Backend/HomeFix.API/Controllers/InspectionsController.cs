using System.Security.Claims;
using HomeFix.API.DTOs.Inspection;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class InspectionsController : ControllerBase
{
    private readonly IInspectionService _service;
    private readonly ITechnicianProfileService _technicians;
    private readonly ICustomerProfileService _customers;

    public InspectionsController(IInspectionService service, ITechnicianProfileService technicians, ICustomerProfileService customers)
    {
        _service = service;
        _technicians = technicians;
        _customers = customers;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<InspectionDto>> GetById(int id)
    {
        var inspection = await _service.GetByIdAsync(id);
        if (inspection == null) return NotFound();
        if (!await CanViewAsync(inspection)) return Forbid();
        return Ok(Map(inspection));
    }

    [HttpGet("request/{requestId:int}")]
    public async Task<ActionResult<InspectionDto>> GetByRequest(int requestId)
    {
        var inspection = await _service.GetByRequestIdAsync(requestId);
        if (inspection == null) return NotFound();
        if (!await CanViewAsync(inspection)) return Forbid();
        return Ok(Map(inspection));
    }

    [HttpGet("mine")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<List<InspectionDto>>> Mine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        return Ok((await _service.GetByTechnicianIdAsync(technician.Id)).Select(Map).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Create(CreateInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });
        var result = await _service.CreateForAcceptedOfferAsync(request.ServiceRequestId, technician.Id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    [HttpPut("{id:int}/schedule")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Schedule(int id, ScheduleInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var result = await _service.ScheduleAsync(id, technician.Id, request.ScheduledAt);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map((await _service.GetByIdAsync(id))!));
    }

    [HttpPost("{id:int}/start")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Start(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var result = await _service.StartAsync(id, technician.Id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map((await _service.GetByIdAsync(id))!));
    }

    [HttpPost("{id:int}/complete")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Complete(int id, CompleteInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var result = await _service.CompleteAsync(id, technician.Id, request.Findings);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map((await _service.GetByIdAsync(id))!));
    }

    [HttpPost("{id:int}/cancel")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Cancel(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var result = await _service.CancelAsync(id, technician.Id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map((await _service.GetByIdAsync(id))!));
    }

    [HttpPost("{id:int}/no-show")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> NoShow(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        var result = await _service.NoShowAsync(id, technician.Id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map((await _service.GetByIdAsync(id))!));
    }

    private async Task<bool> CanViewAsync(HomeFix.DAL.Entities.Inspection inspection)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && technician.Id == inspection.TechnicianId;
        }
        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && customer.Id == inspection.ServiceRequest.CustomerId;
        }
        return false;
    }

    private bool TryGetUserId(out int userId) => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static InspectionDto Map(HomeFix.DAL.Entities.Inspection inspection) => new()
    {
        Id = inspection.Id,
        ServiceRequestId = inspection.ServiceRequestId,
        TechnicianId = inspection.TechnicianId,
        Fee = inspection.Fee,
        ScheduledAt = inspection.ScheduledAt,
        Status = inspection.Status,
        Findings = inspection.Findings,
        CreatedAt = inspection.CreatedAt,
        CompletedAt = inspection.CompletedAt
    };
}
