using System.Security.Claims;
using HomeFix.API.DTOs.Payout;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class PayoutsController : ControllerBase
{
    private readonly IPayoutService _service;

    public PayoutsController(IPayoutService service) => _service = service;

    [HttpGet("me")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<List<PayoutDto>>> GetMine()
    {
        // Payout history is intentionally not exposed until the service supports
        // a caller-scoped lookup by authenticated technician.
        return BadRequest(new { message = "Technician payout history is not enabled yet." });
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<PayoutDto>> GetById(int id)
    {
        var payout = await _service.GetByIdAsync(id);
        return payout is null ? NotFound() : Ok(MapToDto(payout));
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<PayoutDto>>> GetByTechnicianId(int technicianId)
    {
        var payouts = await _service.GetByTechnicianIdAsync(technicianId);
        return Ok(payouts.Select(MapToDto).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<PayoutDto>> Create(CreatePayoutRequest request)
    {
        if (request.Amount <= 0) return BadRequest(new { message = "Payout amount must be greater than zero." });
        if (string.IsNullOrWhiteSpace(request.PaymentMethod)) return BadRequest(new { message = "Payment method is required." });
        if (!TryGetUserId(out var userId)) return Unauthorized();

        // The technician is always derived from the authenticated user inside the BLL;
        // no technician id is accepted from the client.
        var result = await _service.RequestAsync(userId, request.Amount, request.PaymentMethod);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return CreatedAtAction(nameof(GetById), new { id = result.Payout!.Id }, MapToDto(result.Payout));
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<PayoutDto>> Update(int id, UpdatePayoutRequest request)
    {
        var payout = await _service.GetByIdAsync(id);
        if (payout is null) return NotFound();

        payout.Status = request.Status;
        payout.TransactionReference = request.TransactionReference;
        payout.CompletedAt = request.CompletedAt;
        await _service.UpdateAsync(payout);
        return Ok(MapToDto(payout));
    }

    private static PayoutDto MapToDto(Payout payout) => new()
    {
        Id = payout.Id,
        TechnicianId = payout.TechnicianId,
        Amount = payout.Amount,
        Status = payout.Status,
        PaymentMethod = payout.PaymentMethod,
        TransactionReference = payout.TransactionReference,
        RequestedAt = payout.RequestedAt,
        CompletedAt = payout.CompletedAt
    };

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
