namespace HomeFix.API.DTOs.Address;

public class AddressDto
{
    public int Id { get; set; }

    public int CustomerId { get; set; }

    public string? Label { get; set; }

    public string FullAddress { get; set; } = string.Empty;

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }

    public string? BuildingNumber { get; set; }

    public string? FloorNumber { get; set; }

    public string? ApartmentNumber { get; set; }

    public string? AdditionalInstructions { get; set; }

    public bool IsDefault { get; set; }

    public DateTime CreatedAt { get; set; }

    public int? GovernorateId { get; set; }

    public int? CityId { get; set; }
}