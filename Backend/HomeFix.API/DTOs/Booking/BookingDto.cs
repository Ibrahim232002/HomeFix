namespace HomeFix.API.DTOs.Booking;

public class BookingDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int TechnicianId { get; set; }

    public DateTime? AcceptedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public decimal? FinalPrice { get; set; }
    public string? TechnicianNotes { get; set; }
}