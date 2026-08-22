using System.Security.Claims;
using HomeFix.API.DTOs.Inspection;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
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

    public InspectionsController(
        IInspectionService service,
        ITechnicianProfileService technicians,
        ICustomerProfileService customers)
    {
        _service = service;
        _technicians = technicians;
        _customers = customers;
    }

    [HttpPost]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Create(CreateInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.CreateAsync(technician.Id, request.ServiceRequestId, request.ScheduledAt);
        if (!result.Success) return BadRequest(new { message = result.Error });

        return CreatedAtAction(nameof(GetById), new { id = result.Inspection!.Id }, Map(result.Inspection));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<InspectionDto>> GetById(int id)
    {
        var inspection = await _service.GetByIdAsync(id);
        if (inspection == null) return NotFound();
        if (!await CanReadAsync(inspection)) return Forbid();
        return Ok(Map(inspection));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<InspectionDto>> GetByRequest(int serviceRequestId)
    {
        var inspection = await _service.GetByRequestIdAsync(serviceRequestId);
        if (inspection == null) return NotFound();
        if (!await CanReadAsync(inspection)) return Forbid();
        return Ok(Map(inspection));
    }

    [HttpGet("mine")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<List<InspectionDto>>> GetMine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });
        var inspections = await _service.GetByTechnicianIdAsync(technician.Id);
        return Ok(inspections.Select(Map).ToList());
    }

    [HttpPost("{id:int}/schedule")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Schedule(int id, ScheduleInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.ScheduleAsync(technician.Id, id, request.ScheduledAt);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    [HttpPost("{id:int}/start")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Start(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.StartAsync(technician.Id, id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    [HttpPost("{id:int}/complete")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Complete(int id, CompleteInspectionRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.CompleteAsync(technician.Id, id, request.Findings);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    [HttpPost("{id:int}/cancel")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> Cancel(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.CancelAsync(technician.Id, id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    [HttpPost("{id:int}/no-show")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<InspectionDto>> NoShow(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.NoShowAsync(technician.Id, id);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Inspection!));
    }

    private async Task<bool> CanReadAsync(Inspection inspection)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;

        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && inspection.TechnicianId == technician.Id;
        }

        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && inspection.ServiceRequest.CustomerId == customer.Id;
        }

        return false;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static InspectionDto Map(Inspection inspection)
    {
        return new InspectionDto
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
}
