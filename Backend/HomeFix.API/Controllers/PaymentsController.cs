using System.Security.Claims;
using HomeFix.API.DTOs.Payment;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

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

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<PaymentDto>> Create(CreatePaymentRequest request)
    {
        if (request.Amount <= 0)
            return BadRequest(new { message = "Amount must be greater than zero." });

        if (string.IsNullOrWhiteSpace(request.PaymentMethod) || string.IsNullOrWhiteSpace(request.PaymentType))
            return BadRequest(new { message = "Payment type and payment method are required." });

        var serviceRequest = await _requests.GetByIdAsync(request.ServiceRequestId);
        if (serviceRequest?.Booking is null)
            return BadRequest(new { message = "A confirmed booking is required before payment." });

        if (!string.Equals(serviceRequest.Booking.Status, "Confirmed", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { message = "A confirmed booking is required before payment." });

        var expectedAmount = serviceRequest.Booking.FinalPrice ?? serviceRequest.Booking.AgreedPrice;
        if (!expectedAmount.HasValue || expectedAmount.Value <= 0 || expectedAmount.Value != request.Amount)
            return BadRequest(new { message = "Payment amount must match the booking amount." });

        var existingPayments = await _service.GetByRequestIdAsync(request.ServiceRequestId);
        if (existingPayments.Any(p => p.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                                      p.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase)))
            return Conflict(new { message = "An active payment already exists for this service request." });

        var payment = new Payment
        {
            ServiceRequestId = request.ServiceRequestId,
            Amount = request.Amount,
            PaymentType = request.PaymentType.Trim(),
            PaymentMethod = request.PaymentMethod.Trim(),
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            await _service.AddAsync(payment);
        }
        catch (DbUpdateException ex) when (IsActivePaymentUniqueViolation(ex))
        {
            return Conflict(new { message = "An active payment already exists for this service request." });
        }

        return CreatedAtAction(nameof(GetById), new { id = payment.Id }, MapToDto(payment));
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
        var allowed = normalizedCurrent switch
        {
            "pending" => normalizedNext is "pending" or "paid" or "failed" or "cancelled",
            "paid" => normalizedNext == "paid",
            "failed" => normalizedNext == "failed",
            "cancelled" => normalizedNext == "cancelled",
            _ => false
        };
        if (!allowed)
            return Conflict(new { message = "Invalid payment status transition." });

        if (normalizedNext is "pending" or "paid")
        {
            var conflicting = (await _service.GetByRequestIdAsync(payment.ServiceRequestId))
                .Any(p => p.Id != payment.Id &&
                          (p.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                           p.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase)));
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
        catch (DbUpdateException ex) when (IsActivePaymentUniqueViolation(ex))
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

    private static bool IsActivePaymentUniqueViolation(DbUpdateException exception)
    {
        for (Exception? current = exception; current is not null; current = current.InnerException)
        {
            if (current is SqlException sqlException &&
                (sqlException.Number == 2601 || sqlException.Number == 2627) &&
                sqlException.Message.Contains(
                    "UX_Payments_Active_ServiceRequestId",
                    StringComparison.Ordinal))
            {
                return true;
            }
        }

        return false;
    }
}
