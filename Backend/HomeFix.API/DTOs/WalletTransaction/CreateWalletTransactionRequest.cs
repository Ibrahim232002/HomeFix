namespace HomeFix.API.DTOs.WalletTransaction;

public class CreateWalletTransactionRequest
{
    public int WalletId { get; set; }
    public int? ServiceRequestId { get; set; }

    public decimal Amount { get; set; }
    public string TransactionType { get; set; } = string.Empty;
    public string? Description { get; set; }
}