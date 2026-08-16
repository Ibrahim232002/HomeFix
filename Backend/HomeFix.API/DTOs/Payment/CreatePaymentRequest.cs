namespace HomeFix.API.DTOs.Payment;

public class CreatePaymentRequest
{
    public int ServiceRequestId { get; set; }

    public decimal Amount { get; set; }

    public string PaymentType { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
}