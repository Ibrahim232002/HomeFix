namespace HomeFix.API.DTOs.Booking;

public class UpdateBookingRequest
{
    public string? Status { get; set; }
    public decimal? AgreedPrice { get; set; }
    public DateTime? AcceptedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public decimal? FinalPrice { get; set; }
    public string? TechnicianNotes { get; set; }
}