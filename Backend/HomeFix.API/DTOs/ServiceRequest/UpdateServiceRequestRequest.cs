namespace HomeFix.API.DTOs.ServiceRequest;

public class UpdateServiceRequestRequest
{
    public string? Description { get; set; }
    public DateOnly? PreferredDate { get; set; }
    public TimeOnly? PreferredTime { get; set; }
}
