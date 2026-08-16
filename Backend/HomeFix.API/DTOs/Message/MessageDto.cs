namespace HomeFix.API.DTOs.Message;

public class MessageDto
{
    public int Id { get; set; }
    public int ConversationId { get; set; }
    public int SenderId { get; set; }

    public string? MessageText { get; set; }
    public string? AttachmentUrl { get; set; }
    public string? AttachmentType { get; set; }

    public bool IsRead { get; set; }
    public DateTime SentAt { get; set; }
}