namespace HomeFix.API.DTOs.TechnicianProfile;

public class TechnicianProfileDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int? CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public List<int> ServiceIds { get; set; } = new();

    public string? Bio { get; set; }
    public string? ProfileImageUrl { get; set; }

    public int? YearsOfExperience { get; set; }

    public bool IsVerified { get; set; }
    public bool IsAvailable { get; set; }

    public decimal AverageRating { get; set; }
    public int TotalJobs { get; set; }

    public DateTime CreatedAt { get; set; }

    public decimal? CurrentLatitude { get; set; }
    public decimal? CurrentLongitude { get; set; }
    public int? CurrentGovernorateId { get; set; }
    public int? CurrentCityId { get; set; }
}
