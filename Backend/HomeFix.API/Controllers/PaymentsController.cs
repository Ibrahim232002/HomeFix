using System.Security.Claims;
using HomeFix.API.DTOs.Payment;
using HomeFix.BLL.Interfaces;
using HomeFix.BLL.Services;
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
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<PaymentDto>> CreateCash(int serviceRequestId)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();

        var result = await _service.CreateCashForCustomerAsync(serviceRequestId, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });

        return Ok(MapToDto(result.Payment!));
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<PaymentDto>> Create(CreatePaymentRequest request)
    {
        var result = await _service.CreateManualPaymentAsync(
            request.ServiceRequestId,
            request.Amount,
            request.PaymentType,
            request.PaymentMethod);

        if (!result.Success)
        {
            if (result.Error?.Contains("already exists", StringComparison.OrdinalIgnoreCase) == true)
                return Conflict(new { message = result.Error });
            return BadRequest(new { message = result.Error });
        }

        return CreatedAtAction(nameof(GetById), new { id = result.Payment!.Id }, MapToDto(result.Payment));
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<PaymentDto>> Update(int id, UpdatePaymentRequest request)
    {
        var payment = await _service.GetByIdAsync(id);
        if (payment == null) return NotFound();

        var nextStatus = request.Status?.Trim();
        if (string.IsNullOrWhiteSpace(nextStatus))
            return BadRequest(new { message = "Payment status is required." });

        var normalizedNext = nextStatus.ToLowerInvariant();
        var normalizedCurrent = payment.Status.ToLowerInvariant();
        if (!PaymentRules.IsAllowedStatusTransition(normalizedCurrent, normalizedNext))
            return Conflict(new { message = "Invalid payment status transition." });

        if (normalizedNext is "pending" or "paid")
        {
            var conflicting = (await _service.GetByRequestIdAsync(payment.ServiceRequestId))
                .Any(p => p.Id != payment.Id && PaymentRules.IsActive(p));
            if (conflicting)
                return Conflict(new { message = "Another active payment already exists for this service request." });
        }

        payment.Status = normalizedNext switch
        {
            "pending" => "Pending",
            "paid" => "Paid",
            "failed" => "Failed",
            "cancelled" => "Cancelled",
            _ => payment.Status
        };
        payment.TransactionReference = request.TransactionReference?.Trim();
        payment.PaidAt = payment.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase)
            ? request.PaidAt ?? DateTime.UtcNow
            : null;

        try
        {
            await _service.UpdateAsync(payment);
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException)
        {
            return Conflict(new { message = "Another active payment already exists for this service request." });
        }

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
