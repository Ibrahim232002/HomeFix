namespace HomeFix.API.DTOs.CustomerProfile;

public class CustomerProfileDto
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string? ProfileImageUrl { get; set; }

    public DateTime CreatedAt { get; set; }
}