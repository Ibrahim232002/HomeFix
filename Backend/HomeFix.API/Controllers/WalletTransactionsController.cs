using HomeFix.API.DTOs.WalletTransaction;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WalletTransactionsController : ControllerBase
{
    private readonly IWalletTransactionService _service;

    public WalletTransactionsController(
        IWalletTransactionService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<WalletTransactionDto>> GetById(int id)
    {
        var transaction = await _service.GetByIdAsync(id);

        if (transaction == null)
            return NotFound();

        return Ok(MapToDto(transaction));
    }

    [HttpGet("wallet/{walletId:int}")]
    public async Task<ActionResult<List<WalletTransactionDto>>>
        GetByWalletId(int walletId)
    {
        var transactions =
            await _service.GetByWalletIdAsync(walletId);

        return Ok(transactions.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<WalletTransactionDto>> Create(
        CreateWalletTransactionRequest request)
    {
        var transaction = new WalletTransaction
        {
            WalletId = request.WalletId,
            ServiceRequestId = request.ServiceRequestId,
            Amount = request.Amount,
            TransactionType = request.TransactionType,
            Description = request.Description,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(transaction);

        return CreatedAtAction(
            nameof(GetById),
            new { id = transaction.Id },
            MapToDto(transaction));
    }

    private static WalletTransactionDto MapToDto(
        WalletTransaction transaction)
    {
        return new WalletTransactionDto
        {
            Id = transaction.Id,
            WalletId = transaction.WalletId,
            ServiceRequestId = transaction.ServiceRequestId,
            Amount = transaction.Amount,
            TransactionType = transaction.TransactionType,
            Description = transaction.Description,
            CreatedAt = transaction.CreatedAt
        };
    }
}