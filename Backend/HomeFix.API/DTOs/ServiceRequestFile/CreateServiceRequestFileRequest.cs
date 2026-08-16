namespace HomeFix.API.DTOs.ServiceRequestFile;

public class CreateServiceRequestFileRequest
{
    public int ServiceRequestId { get; set; }

    public string FileUrl { get; set; } = string.Empty;

    public string FileType { get; set; } = string.Empty;
}