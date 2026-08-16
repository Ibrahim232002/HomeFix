namespace HomeFix.API.DTOs.Payout;

public class UpdatePayoutRequest
{
    public string Status { get; set; } = string.Empty;

    public string? TransactionReference { get; set; }

    public DateTime? CompletedAt { get; set; }
}