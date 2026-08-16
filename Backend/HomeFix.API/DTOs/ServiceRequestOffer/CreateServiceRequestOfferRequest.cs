namespace HomeFix.API.DTOs.ServiceRequestOffer;

public class CreateServiceRequestOfferRequest
{
    public int ServiceRequestId { get; set; }
    public int TechnicianId { get; set; }
    public decimal ProposedPrice { get; set; }
    public string? TechnicianNote { get; set; }
}
