namespace HomeFix.API.DTOs.Conversation;

public class ConversationDto
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int CustomerId { get; set; }
    public int TechnicianId { get; set; }
    public DateTime CreatedAt { get; set; }
}