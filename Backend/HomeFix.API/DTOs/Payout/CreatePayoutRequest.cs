namespace HomeFix.API.DTOs.Payout;

public class CreatePayoutRequest
{
    public int TechnicianId { get; set; }

    public decimal Amount { get; set; }

    public string PaymentMethod { get; set; } = string.Empty;
}