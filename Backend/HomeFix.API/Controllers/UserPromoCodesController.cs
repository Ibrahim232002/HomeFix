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

    public UserPromoCodesController(
        IUserPromoCodeService service,
        IServiceRequestService requests,
        ICustomerProfileService customers)
    {
        _service = service;
        _requests = requests;
        _customers = customers;
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

        var result = await _service.ApplyAsync(userId, request.ServiceRequestId, request.PromoCodeId);
        if (!result.Success)
        {
            if (result.Error?.Contains("already been applied", StringComparison.OrdinalIgnoreCase) == true)
                return Conflict(new { message = result.Error });
            return BadRequest(new { message = result.Error });
        }

        return CreatedAtAction(nameof(GetById), new { id = result.UserPromoCode!.Id }, MapToDto(result.UserPromoCode));
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