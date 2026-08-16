namespace HomeFix.API.DTOs.City;

public class CityDto
{
    public int Id { get; set; }

    public int GovernorateId { get; set; }

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }
}