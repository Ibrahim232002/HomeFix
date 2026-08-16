namespace HomeFix.API.DTOs.Payout;

public class PayoutDto
{
    public int Id { get; set; }
    public int TechnicianId { get; set; }

    public decimal Amount { get; set; }

    public string Status { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;

    public string? TransactionReference { get; set; }

    public DateTime RequestedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}