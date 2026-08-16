namespace HomeFix.API.DTOs.ServiceRequest;

public class ServiceRequestDto
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public int ServiceId { get; set; }
    public int AddressId { get; set; }

    public string Description { get; set; } = string.Empty;

    public DateOnly? PreferredDate { get; set; }
    public TimeOnly? PreferredTime { get; set; }

    public string Status { get; set; } = string.Empty;
    public decimal VisitFee { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}