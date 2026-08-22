namespace HomeFix.API.DTOs.ServiceQuote;

public class CreateServiceQuoteRequest
{
    public int InspectionId { get; set; }
    public decimal Amount { get; set; }
    public string? Notes { get; set; }
    public DateTime? ExpiresAt { get; set; }
}
