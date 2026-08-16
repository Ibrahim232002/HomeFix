namespace HomeFix.API.DTOs.Message;

public class CreateMessageRequest
{
    public int ConversationId { get; set; }
    public int SenderId { get; set; }

    public string? MessageText { get; set; }
    public string? AttachmentUrl { get; set; }
    public string? AttachmentType { get; set; }
}