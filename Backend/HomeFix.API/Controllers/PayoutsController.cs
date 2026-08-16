using HomeFix.API.DTOs.Payout;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PayoutsController : ControllerBase
{
    private readonly IPayoutService _service;

    public PayoutsController(IPayoutService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PayoutDto>> GetById(int id)
    {
        var payout = await _service.GetByIdAsync(id);

        if (payout == null)
            return NotFound();

        return Ok(MapToDto(payout));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<PayoutDto>>> GetByTechnicianId(
        int technicianId)
    {
        var payouts =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(payouts.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<PayoutDto>> Create(
        CreatePayoutRequest request)
    {
        var payout = new Payout
        {
            TechnicianId = request.TechnicianId,
            Amount = request.Amount,
            PaymentMethod = request.PaymentMethod,
            Status = "Pending",
            RequestedAt = DateTime.UtcNow
        };

        await _service.AddAsync(payout);

        return CreatedAtAction(
            nameof(GetById),
            new { id = payout.Id },
            MapToDto(payout));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<PayoutDto>> Update(
        int id,
        UpdatePayoutRequest request)
    {
        var payout = await _service.GetByIdAsync(id);

        if (payout == null)
            return NotFound();

        payout.Status = request.Status;
        payout.TransactionReference = request.TransactionReference;
        payout.CompletedAt = request.CompletedAt;

        await _service.UpdateAsync(payout);

        return Ok(MapToDto(payout));
    }

    private static PayoutDto MapToDto(Payout payout)
    {
        return new PayoutDto
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
    }
}