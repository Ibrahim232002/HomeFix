namespace HomeFix.API.DTOs.Conversation;

public class CreateConversationRequest
{
    public int ServiceRequestId { get; set; }
    public int CustomerId { get; set; }
    public int TechnicianId { get; set; }
}