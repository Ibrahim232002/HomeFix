namespace HomeFix.API.DTOs.SupportTicket;

public class CreateSupportTicketRequest
{
    public int UserId { get; set; }
    public int? ServiceRequestId { get; set; }

    public string Subject { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public string Priority { get; set; } = "Medium";
}