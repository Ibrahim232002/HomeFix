namespace HomeFix.API.DTOs.Booking;

public class UpdateBookingRequest
{
    public DateTime? AcceptedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public decimal? FinalPrice { get; set; }
    public string? TechnicianNotes { get; set; }
}