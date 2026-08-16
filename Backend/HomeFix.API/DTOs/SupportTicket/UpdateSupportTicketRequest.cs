namespace HomeFix.API.DTOs.SupportTicket;

public class UpdateSupportTicketRequest
{
    public string Description { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
}