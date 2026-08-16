namespace HomeFix.API.DTOs.SupportMessage;

public class SupportMessageDto
{
    public int Id { get; set; }
    public int SupportTicketId { get; set; }
    public int SenderId { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? AttachmentUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}