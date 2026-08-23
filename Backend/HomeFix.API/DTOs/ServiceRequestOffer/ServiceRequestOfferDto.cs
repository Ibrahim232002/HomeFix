namespace HomeFix.API.DTOs.ServiceRequestOffer;

public class ServiceRequestOfferDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int ServiceId { get; set; }
    public int PricingMode { get; set; }
    public int TechnicianId { get; set; }
    public string? TechnicianName { get; set; }
    public decimal ProposedPrice { get; set; }
    public string? TechnicianNote { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}
