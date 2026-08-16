using System.Security.Claims;
using HomeFix.API.DTOs.Payment;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customers;
    private readonly ITechnicianProfileService _technicians;

    public PaymentsController(
        IPaymentService service,
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
    public async Task<ActionResult<PaymentDto>> GetById(int id)
    {
        var payment = await _service.GetByIdAsync(id);
        if (payment == null) return NotFound();
        if (!await CanAccessRequestAsync(payment.ServiceRequestId)) return Forbid();
        return Ok(MapToDto(payment));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<PaymentDto>>> GetByRequestId(int serviceRequestId)
    {
        if (!await CanAccessRequestAsync(serviceRequestId)) return Forbid();
        var payments = await _service.GetByRequestIdAsync(serviceRequestId);
        return Ok(payments.Select(MapToDto).ToList());
    }

    [HttpPost("cash/{serviceRequestId:int}")]
    public async Task<ActionResult<PaymentDto>> CreateCash(int serviceRequestId)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();

        var result = await _service.CreateCashForCustomerAsync(serviceRequestId, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });

        return Ok(MapToDto(result.Payment!));
    }

    // Administrative reconciliation endpoint. Customers/technicians must not
    // be able to set payment status, amount, or provider references directly.
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<PaymentDto>> Create(CreatePaymentRequest request)
    {
        if (request.Amount <= 0) return BadRequest(new { message = "Amount must be greater than zero." });

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
        return CreatedAtAction(nameof(GetById), new { id = payment.Id }, MapToDto(payment));
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<PaymentDto>> Update(int id, UpdatePaymentRequest request)
    {
        var payment = await _service.GetByIdAsync(id);
        if (payment == null) return NotFound();

        payment.Status = request.Status;
        payment.TransactionReference = request.TransactionReference;
        payment.PaidAt = request.PaidAt;
        await _service.UpdateAsync(payment);
        return Ok(MapToDto(payment));
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

    private static PaymentDto MapToDto(Payment payment) => new()
    {
        Id = payment.Id,
        ServiceRequestId = payment.ServiceRequestId,
        Amount = payment.Amount,
        PaymentType = payment.PaymentType,
        PaymentMethod = payment.PaymentMethod,
        Status = payment.Status,
        TransactionReference = payment.TransactionReference,
        Provider = payment.Provider,
        ProviderTransactionId = payment.ProviderTransactionId,
        PaidAt = payment.PaidAt,
        CreatedAt = payment.CreatedAt
    };

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
