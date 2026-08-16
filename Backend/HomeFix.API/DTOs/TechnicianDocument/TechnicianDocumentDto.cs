namespace HomeFix.API.DTOs.TechnicianDocument;

public class TechnicianDocumentDto
{
    public int Id { get; set; }
    public int TechnicianId { get; set; }

    public string DocumentType { get; set; } = string.Empty;
    public string DocumentUrl { get; set; } = string.Empty;

    public DateTime UploadedAt { get; set; }

    public string Status { get; set; } = string.Empty;

    public string? RejectionReason { get; set; }

    public DateTime? ReviewedAt { get; set; }
}