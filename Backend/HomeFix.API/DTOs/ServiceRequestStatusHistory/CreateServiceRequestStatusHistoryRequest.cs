namespace HomeFix.API.DTOs.ServiceRequestStatusHistory;

public class CreateServiceRequestStatusHistoryRequest
{
    public int ServiceRequestId { get; set; }

    public string? OldStatus { get; set; }

    public string NewStatus { get; set; } = string.Empty;

    public int ChangedByUserId { get; set; }
}