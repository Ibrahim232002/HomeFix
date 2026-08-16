namespace HomeFix.API.DTOs.ServiceRequest;

public class CreateServiceRequestRequest
{
    public int CustomerId { get; set; }

    public int ServiceId { get; set; }

    public int AddressId { get; set; }

    public string Description { get; set; } = string.Empty;

    public DateOnly? PreferredDate { get; set; }

    public TimeOnly? PreferredTime { get; set; }

    public string Status { get; set; } = "Pending";

    public decimal VisitFee { get; set; }
}