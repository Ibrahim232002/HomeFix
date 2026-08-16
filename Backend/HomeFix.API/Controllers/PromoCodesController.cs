using HomeFix.API.DTOs.PromoCode;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PromoCodesController : ControllerBase
{
    private readonly IPromoCodeService _service;

    public PromoCodesController(IPromoCodeService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PromoCodeDto>> GetById(int id)
    {
        var promoCode = await _service.GetByIdAsync(id);

        if (promoCode == null)
            return NotFound();

        return Ok(MapToDto(promoCode));
    }

    [HttpGet("code/{code}")]
    public async Task<ActionResult<PromoCodeDto>> GetByCode(
        string code)
    {
        var promoCode = await _service.GetByCodeAsync(code);

        if (promoCode == null)
            return NotFound();

        return Ok(MapToDto(promoCode));
    }

    [HttpGet("active")]
    public async Task<ActionResult<List<PromoCodeDto>>> GetActive()
    {
        var promoCodes = await _service.GetActiveAsync();

        return Ok(promoCodes.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<PromoCodeDto>> Create(
        CreatePromoCodeRequest request)
    {
        var promoCode = new PromoCode
        {
            Code = request.Code,
            DiscountType = request.DiscountType,
            DiscountValue = request.DiscountValue,
            MaxUses = request.MaxUses,
            UsedCount = 0,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true
        };

        await _service.AddAsync(promoCode);

        return CreatedAtAction(
            nameof(GetById),
            new { id = promoCode.Id },
            MapToDto(promoCode));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<PromoCodeDto>> Update(
        int id,
        UpdatePromoCodeRequest request)
    {
        var promoCode = await _service.GetByIdAsync(id);

        if (promoCode == null)
            return NotFound();

        promoCode.Code = request.Code;
        promoCode.DiscountType = request.DiscountType;
        promoCode.DiscountValue = request.DiscountValue;
        promoCode.MaxUses = request.MaxUses;
        promoCode.StartDate = request.StartDate;
        promoCode.EndDate = request.EndDate;
        promoCode.IsActive = request.IsActive;

        await _service.UpdateAsync(promoCode);

        return Ok(MapToDto(promoCode));
    }

    private static PromoCodeDto MapToDto(PromoCode promoCode)
    {
        return new PromoCodeDto
        {
            Id = promoCode.Id,
            Code = promoCode.Code,
            DiscountType = promoCode.DiscountType,
            DiscountValue = promoCode.DiscountValue,
            MaxUses = promoCode.MaxUses,
            UsedCount = promoCode.UsedCount,
            StartDate = promoCode.StartDate,
            EndDate = promoCode.EndDate,
            IsActive = promoCode.IsActive
        };
    }
}