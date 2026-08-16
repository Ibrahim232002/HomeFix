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
    public async Task<ActionResult<List<PayoutDto>>> GetMine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        // The BLL currently exposes payout lookup by technician id; caller-specific mapping
        // stays in the service layer in the next hardening pass.
        return BadRequest(new { message = "Use the technician payout history endpoint after technician profile mapping is enabled." });
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
    public async Task<ActionResult<PayoutDto>> Create(CreatePayoutRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
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
