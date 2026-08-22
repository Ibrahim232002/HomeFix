namespace HomeFix.API.DTOs.Inspection;

public class InspectionDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int TechnicianId { get; set; }
    public decimal Fee { get; set; }
    public DateTime ScheduledAt { get; set; }
    public string Status { get; set; } = null!;
    public string? Findings { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
