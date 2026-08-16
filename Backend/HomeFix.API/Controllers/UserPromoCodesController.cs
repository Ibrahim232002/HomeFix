using HomeFix.API.DTOs.UserPromoCode;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserPromoCodesController : ControllerBase
{
    private readonly IUserPromoCodeService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customers;
    private readonly IPromoCodeService _promoCodes;

    public UserPromoCodesController(
        IUserPromoCodeService service,
        IServiceRequestService requests,
        ICustomerProfileService customers,
        IPromoCodeService promoCodes)
    {
        _service = service;
        _requests = requests;
        _customers = customers;
        _promoCodes = promoCodes;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<UserPromoCodeDto>> GetById(int id)
    {
        var userPromoCode = await _service.GetByIdAsync(id);
        if (userPromoCode == null) return NotFound();
        if (!await CanAccessUserAsync(userPromoCode.UserId)) return Forbid();
        return Ok(MapToDto(userPromoCode));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<UserPromoCodeDto>> GetByRequestId(int serviceRequestId)
    {
        var userPromoCode = await _service.GetByRequestIdAsync(serviceRequestId);
        if (userPromoCode == null) return NotFound();
        if (!await CanAccessUserAsync(userPromoCode.UserId)) return Forbid();
        return Ok(MapToDto(userPromoCode));
    }

    [HttpPost]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<UserPromoCodeDto>> Create(CreateUserPromoCodeRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();

        var customer = await _customers.GetByUserIdAsync(userId);
        if (customer == null) return NotFound(new { message = "Customer profile not found." });

        var serviceRequest = await _requests.GetByIdAsync(request.ServiceRequestId);
        if (serviceRequest == null) return NotFound(new { message = "Service request not found." });
        if (serviceRequest.CustomerId != customer.Id) return Forbid();

        var existing = await _service.GetByRequestIdAsync(request.ServiceRequestId);
        if (existing != null) return Conflict(new { message = "A promo code has already been applied to this service request." });

        var promo = await _promoCodes.GetByIdAsync(request.PromoCodeId);
        if (promo == null || !promo.IsActive) return BadRequest(new { message = "Invalid or inactive promo code." });
        var now = DateTime.UtcNow;
        if (now < promo.StartDate || now > promo.EndDate) return BadRequest(new { message = "Promo code is outside its validity period." });
        if (promo.MaxUses.HasValue && promo.UsedCount >= promo.MaxUses.Value) return BadRequest(new { message = "Promo code usage limit has been reached." });

        // Never trust UserId or DiscountAmount sent by the client.
        var baseAmount = serviceRequest.VisitFee;
        decimal discountAmount;
        if (promo.DiscountType.Equals("Percentage", StringComparison.OrdinalIgnoreCase))
            discountAmount = baseAmount * (promo.DiscountValue / 100m);
        else if (promo.DiscountType.Equals("Fixed", StringComparison.OrdinalIgnoreCase))
            discountAmount = promo.DiscountValue;
        else
            return BadRequest(new { message = "Unsupported promo code discount type." });

        discountAmount = Math.Max(0m, Math.Min(discountAmount, baseAmount));

        var userPromoCode = new UserPromoCode
        {
            UserId = userId,
            PromoCodeId = promo.Id,
            ServiceRequestId = serviceRequest.Id,
            DiscountAmount = discountAmount,
            UsedAt = now
        };

        promo.UsedCount++;
        await _service.AddAsync(userPromoCode);
        await _promoCodes.UpdateAsync(promo);

        return CreatedAtAction(nameof(GetById), new { id = userPromoCode.Id }, MapToDto(userPromoCode));
    }

    private async Task<bool> CanAccessUserAsync(int ownerUserId)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        return userId == ownerUserId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static UserPromoCodeDto MapToDto(UserPromoCode userPromoCode) => new()
    {
        Id = userPromoCode.Id,
        UserId = userPromoCode.UserId,
        PromoCodeId = userPromoCode.PromoCodeId,
        ServiceRequestId = userPromoCode.ServiceRequestId,
        DiscountAmount = userPromoCode.DiscountAmount,
        UsedAt = userPromoCode.UsedAt
    };
}