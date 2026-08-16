namespace HomeFix.API.DTOs.Review;

public class CreateReviewRequest
{
    public int ServiceRequestId { get; set; }
    public int CustomerId { get; set; }
    public int TechnicianId { get; set; }

    public int Rating { get; set; }
    public string? Comment { get; set; }
}