namespace HomeFix.API.DTOs.ServiceRequestFile;

public class ServiceRequestFileDto
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public string FileUrl { get; set; } = string.Empty;

    public string FileType { get; set; } = string.Empty;

    public DateTime UploadedAt { get; set; }
}