namespace HomeFix.API.DTOs.SupportMessage;

public class CreateSupportMessageRequest
{
    public int SupportTicketId { get; set; }
    public int SenderId { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? AttachmentUrl { get; set; }
}