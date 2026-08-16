namespace HomeFix.API.DTOs.WalletTransaction;

public class WalletTransactionDto
{
    public int Id { get; set; }
    public int WalletId { get; set; }
    public int? ServiceRequestId { get; set; }

    public decimal Amount { get; set; }
    public decimal? BalanceBefore { get; set; }
    public decimal? BalanceAfter { get; set; }
    public string TransactionType { get; set; } = string.Empty;
    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }
}