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

    // Read-only presentation fields. Mutable values remain sourced from the request itself.
    public string? ServiceName { get; set; }
    public string? ServiceDescription { get; set; }
    public string? ServiceImageUrl { get; set; }
    public int? EstimatedDurationMinutes { get; set; }

    public string? AddressLabel { get; set; }
    public string? FullAddress { get; set; }
    public string? BuildingNumber { get; set; }
    public string? FloorNumber { get; set; }
    public string? ApartmentNumber { get; set; }
    public string? AdditionalInstructions { get; set; }
    public int? GovernorateId { get; set; }
    public int? CityId { get; set; }
    public string? GovernorateName { get; set; }
    public string? CityName { get; set; }
}