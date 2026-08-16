using System.Security.Claims;
using HomeFix.API.DTOs.TechnicianWallet;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class TechnicianWalletsController : ControllerBase
{
    private readonly ITechnicianWalletService _service;

    public TechnicianWalletsController(ITechnicianWalletService service) => _service = service;

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TechnicianWalletDto>> GetById(int id)
    {
        var wallet = await _service.GetByIdAsync(id);
        return wallet is null ? NotFound() : Ok(MapToDto(wallet));
    }

    [HttpGet("me")]
    public async Task<ActionResult<TechnicianWalletDto>> GetMine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var wallet = await _service.GetByUserIdAsync(userId);
        return wallet is null ? NotFound() : Ok(MapToDto(wallet));
    }

    // Wallets are created as part of technician onboarding; there is no public create endpoint.
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<TechnicianWalletDto>> Create(CreateTechnicianWalletRequest request)
    {
        var wallet = new TechnicianWallet
        {
            TechnicianId = request.TechnicianId,
            Balance = 0,
            UpdatedAt = DateTime.UtcNow
        };
        await _service.AddAsync(wallet);
        return CreatedAtAction(nameof(GetById), new { id = wallet.Id }, MapToDto(wallet));
    }

    // Balance must never be written directly. Credits/debits happen through business operations.
    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public IActionResult Update(int id, UpdateTechnicianWalletRequest request)
        => BadRequest(new { message = "Wallet balance cannot be modified directly. Use payout/payment settlement workflows." });

    private static TechnicianWalletDto MapToDto(TechnicianWallet wallet) => new()
    {
        Id = wallet.Id,
        TechnicianId = wallet.TechnicianId,
        Balance = wallet.Balance,
        UpdatedAt = wallet.UpdatedAt
    };

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
