namespace HomeFix.API.DTOs.TechnicianAvailability;

public class UpdateTechnicianAvailabilityRequest
{
    public byte DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }

    public bool IsAvailable { get; set; }
}