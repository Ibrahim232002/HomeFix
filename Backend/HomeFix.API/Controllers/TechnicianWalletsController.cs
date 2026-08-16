using HomeFix.API.DTOs.TechnicianWallet;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TechnicianWalletsController : ControllerBase
{
    private readonly ITechnicianWalletService _service;

    public TechnicianWalletsController(
        ITechnicianWalletService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianWalletDto>> GetById(int id)
    {
        var wallet = await _service.GetByIdAsync(id);

        if (wallet == null)
            return NotFound();

        return Ok(MapToDto(wallet));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<TechnicianWalletDto>>
        GetByTechnicianId(int technicianId)
    {
        var wallet =
            await _service.GetByTechnicianIdAsync(technicianId);

        if (wallet == null)
            return NotFound();

        return Ok(MapToDto(wallet));
    }

    [HttpPost]
    public async Task<ActionResult<TechnicianWalletDto>> Create(
        CreateTechnicianWalletRequest request)
    {
        var wallet = new TechnicianWallet
        {
            TechnicianId = request.TechnicianId,
            Balance = 0,
            UpdatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(wallet);

        return CreatedAtAction(
            nameof(GetById),
            new { id = wallet.Id },
            MapToDto(wallet));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<TechnicianWalletDto>> Update(
        int id,
        UpdateTechnicianWalletRequest request)
    {
        var wallet = await _service.GetByIdAsync(id);

        if (wallet == null)
            return NotFound();

        wallet.Balance = request.Balance;
        wallet.UpdatedAt = DateTime.UtcNow;

        await _service.UpdateAsync(wallet);

        return Ok(MapToDto(wallet));
    }

    private static TechnicianWalletDto MapToDto(
        TechnicianWallet wallet)
    {
        return new TechnicianWalletDto
        {
            Id = wallet.Id,
            TechnicianId = wallet.TechnicianId,
            Balance = wallet.Balance,
            UpdatedAt = wallet.UpdatedAt
        };
    }
}