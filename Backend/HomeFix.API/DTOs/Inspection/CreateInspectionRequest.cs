namespace HomeFix.API.DTOs.Inspection;

public class CreateInspectionRequest
{
    public int ServiceRequestId { get; set; }
    public DateTime ScheduledAt { get; set; }
}
