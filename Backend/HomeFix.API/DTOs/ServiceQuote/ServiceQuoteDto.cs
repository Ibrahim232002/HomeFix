namespace HomeFix.API.DTOs.ServiceQuote;

public class ServiceQuoteDto
{
    public int Id { get; set; }
    public int InspectionId { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = null!;
    public string? Notes { get; set; }
    public int Revision { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
}
