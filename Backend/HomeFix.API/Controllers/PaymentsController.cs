using HomeFix.API.DTOs.Payment;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _service;

    public PaymentsController(IPaymentService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PaymentDto>> GetById(int id)
    {
        var payment = await _service.GetByIdAsync(id);

        if (payment == null)
            return NotFound();

        return Ok(MapToDto(payment));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<PaymentDto>>> GetByRequestId(
        int serviceRequestId)
    {
        var payments =
            await _service.GetByRequestIdAsync(serviceRequestId);

        return Ok(payments.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<PaymentDto>> Create(
        CreatePaymentRequest request)
    {
        var payment = new Payment
        {
            ServiceRequestId = request.ServiceRequestId,
            Amount = request.Amount,
            PaymentType = request.PaymentType,
            PaymentMethod = request.PaymentMethod,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(payment);

        return CreatedAtAction(
            nameof(GetById),
            new { id = payment.Id },
            MapToDto(payment));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<PaymentDto>> Update(
        int id,
        UpdatePaymentRequest request)
    {
        var payment = await _service.GetByIdAsync(id);

        if (payment == null)
            return NotFound();

        payment.Status = request.Status;
        payment.TransactionReference = request.TransactionReference;
        payment.PaidAt = request.PaidAt;

        await _service.UpdateAsync(payment);

        return Ok(MapToDto(payment));
    }

    private static PaymentDto MapToDto(Payment payment)
    {
        return new PaymentDto
        {
            Id = payment.Id,
            ServiceRequestId = payment.ServiceRequestId,
            Amount = payment.Amount,
            PaymentType = payment.PaymentType,
            PaymentMethod = payment.PaymentMethod,
            Status = payment.Status,
            TransactionReference = payment.TransactionReference,
            PaidAt = payment.PaidAt,
            CreatedAt = payment.CreatedAt
        };
    }
}