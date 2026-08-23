using System.Security.Claims;
using HomeFix.API.DTOs.ServiceQuote;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ServiceQuotesController : ControllerBase
{
    private readonly IServiceQuoteService _service;
    private readonly IInspectionService _inspections;
    private readonly ITechnicianProfileService _technicians;
    private readonly ICustomerProfileService _customers;

    public ServiceQuotesController(
        IServiceQuoteService service,
        IInspectionService inspections,
        ITechnicianProfileService technicians,
        ICustomerProfileService customers)
    {
        _service = service;
        _inspections = inspections;
        _technicians = technicians;
        _customers = customers;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceQuoteDto>> GetById(int id)
    {
        var quote = await _service.GetByIdAsync(id);
        if (quote == null) return NotFound();
        if (!await CanReadAsync(quote)) return Forbid();
        return Ok(Map(quote));
    }

    [HttpGet("inspection/{inspectionId:int}")]
    public async Task<ActionResult<List<ServiceQuoteDto>>> GetByInspection(int inspectionId)
    {
        var inspection = await _inspections.GetByIdAsync(inspectionId);
        if (inspection == null) return NotFound();
        if (!await CanReadInspectionAsync(inspection)) return Forbid();

        var quotes = await _service.GetByInspectionIdAsync(inspectionId);
        return Ok(quotes.Select(Map).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<ServiceQuoteDto>> Create(CreateServiceQuoteRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.CreateAsync(
            technician.Id,
            request.InspectionId,
            request.Amount,
            request.Notes,
            request.ExpiresAt);

        if (!result.Success) return BadRequest(new { message = result.Error });
        return CreatedAtAction(nameof(GetById), new { id = result.Quote!.Id }, Map(result.Quote));
    }

    [HttpPost("{id:int}/revision")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<ServiceQuoteDto>> CreateRevision(int id, CreateServiceQuoteRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicians.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });

        var result = await _service.CreateRevisionAsync(
            technician.Id,
            id,
            request.Amount,
            request.Notes,
            request.ExpiresAt);

        if (!result.Success) return BadRequest(new { message = result.Error });
        return CreatedAtAction(nameof(GetById), new { id = result.Quote!.Id }, Map(result.Quote));
    }

    [HttpPost("{id:int}/accept")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Accept(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var result = await _service.AcceptAsync(id, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Quote accepted." });
    }

    [HttpPost("{id:int}/reject")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Reject(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var result = await _service.RejectAsync(id, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Quote rejected." });
    }

    private async Task<bool> CanReadAsync(ServiceQuote quote)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;

        if (User.IsInRole("Technician"))
        {
            var technician = await _technicians.GetByUserIdAsync(userId);
            return technician != null && quote.Inspection.TechnicianId == technician.Id;
        }

        if (User.IsInRole("Customer"))
        {
            var customer = await _customers.GetByUserIdAsync(userId);
            return customer != null && quote.Inspection.ServiceRequest.CustomerId == customer.Id;
        }

        return false;
    }

    private async Task<bool> CanReadInspectionAsync(Inspection inspection)
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

    private static ServiceQuoteDto Map(ServiceQuote quote) => new()
    {
        Id = quote.Id,
        InspectionId = quote.InspectionId,
        Amount = quote.Amount,
        Status = quote.Status,
        Notes = quote.Notes,
        Revision = quote.Revision,
        CreatedAt = quote.CreatedAt,
        ExpiresAt = quote.ExpiresAt
    };
}
