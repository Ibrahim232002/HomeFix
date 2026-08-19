namespace HomeFix.API.DTOs.TechnicianProfile;

public class UpdateTechnicianProfileRequest
{
    public string? Bio { get; set; }
    public string? ProfileImageUrl { get; set; }

    public int? YearsOfExperience { get; set; }

    public bool IsVerified { get; set; }
    public bool IsAvailable { get; set; }

    public decimal? CurrentLatitude { get; set; }
    public decimal? CurrentLongitude { get; set; }
    public int? CurrentGovernorateId { get; set; }
    public int? CurrentCityId { get; set; }
}