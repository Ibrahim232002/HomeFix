namespace HomeFix.API.DTOs.Payment;

public class UpdatePaymentRequest
{
    public string Status { get; set; } = string.Empty;

    public string? TransactionReference { get; set; }

    public DateTime? PaidAt { get; set; }
}