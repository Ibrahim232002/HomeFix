namespace HomeFix.API.DTOs.CustomerProfile;

public class CreateCustomerProfileRequest
{
    public int UserId { get; set; }

    public string? ProfileImageUrl { get; set; }
}