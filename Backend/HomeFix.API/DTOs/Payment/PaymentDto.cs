namespace HomeFix.API.DTOs.Payment;

public class PaymentDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }

    public decimal Amount { get; set; }

    public string PaymentType { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;

    public string? TransactionReference { get; set; }
    public string? Provider { get; set; }
    public string? ProviderTransactionId { get; set; }

    public DateTime? PaidAt { get; set; }
    public DateTime CreatedAt { get; set; }
}