namespace HomeFix.API.DTOs.Booking;

public class BookingDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int TechnicianId { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal? AgreedPrice { get; set; }

    public DateTime? AcceptedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public decimal? FinalPrice { get; set; }
    public string? TechnicianNotes { get; set; }

    // Presentation-only fields populated from the related authorized booking graph.
    public string? ServiceName { get; set; }
    public string? CustomerName { get; set; }
    public string? CustomerPhone { get; set; }
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