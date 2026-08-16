namespace HomeFix.API.DTOs.TechnicianDocument;

public class CreateTechnicianDocumentRequest
{
    public int TechnicianId { get; set; }

    public string DocumentType { get; set; } = string.Empty;
    public string DocumentUrl { get; set; } = string.Empty;
}