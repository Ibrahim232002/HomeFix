namespace HomeFix.API.DTOs.TechnicianDocument;

public class UpdateTechnicianDocumentRequest
{
    public string Status { get; set; } = string.Empty;

    public string? RejectionReason { get; set; }

    public DateTime? ReviewedAt { get; set; }
}