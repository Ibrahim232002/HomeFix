using HomeFix.API.DTOs.UserPromoCode;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserPromoCodesController : ControllerBase
{
    private readonly IUserPromoCodeService _service;

    public UserPromoCodesController(IUserPromoCodeService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<UserPromoCodeDto>> GetById(int id)
    {
        var userPromoCode = await _service.GetByIdAsync(id);

        if (userPromoCode == null)
            return NotFound();

        return Ok(MapToDto(userPromoCode));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<UserPromoCodeDto>>
        GetByRequestId(int serviceRequestId)
    {
        var userPromoCode =
            await _service.GetByRequestIdAsync(serviceRequestId);

        if (userPromoCode == null)
            return NotFound();

        return Ok(MapToDto(userPromoCode));
    }

    [HttpPost]
    public async Task<ActionResult<UserPromoCodeDto>> Create(
        CreateUserPromoCodeRequest request)
    {
        var userPromoCode = new UserPromoCode
        {
            UserId = request.UserId,
            PromoCodeId = request.PromoCodeId,
            ServiceRequestId = request.ServiceRequestId,
            DiscountAmount = request.DiscountAmount,
            UsedAt = DateTime.UtcNow
        };

        await _service.AddAsync(userPromoCode);

        return CreatedAtAction(
            nameof(GetById),
            new { id = userPromoCode.Id },
            MapToDto(userPromoCode));
    }

    private static UserPromoCodeDto MapToDto(
        UserPromoCode userPromoCode)
    {
        return new UserPromoCodeDto
        {
            Id = userPromoCode.Id,
            UserId = userPromoCode.UserId,
            PromoCodeId = userPromoCode.PromoCodeId,
            ServiceRequestId = userPromoCode.ServiceRequestId,
            DiscountAmount = userPromoCode.DiscountAmount,
            UsedAt = userPromoCode.UsedAt
        };
    }
}