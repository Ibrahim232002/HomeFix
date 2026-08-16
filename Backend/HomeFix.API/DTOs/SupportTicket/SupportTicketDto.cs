namespace HomeFix.API.DTOs.SupportTicket;

public class SupportTicketDto
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public int? ServiceRequestId { get; set; }

    public string Subject { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}