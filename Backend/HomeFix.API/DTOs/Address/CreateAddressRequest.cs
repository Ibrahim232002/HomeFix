namespace HomeFix.API.DTOs.Address;

public class CreateAddressRequest
{
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

    public int? GovernorateId { get; set; }

    public int? CityId { get; set; }
}