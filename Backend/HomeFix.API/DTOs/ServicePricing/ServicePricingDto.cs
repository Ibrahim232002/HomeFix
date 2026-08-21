namespace HomeFix.API.DTOs.ServicePricing;

public class ServicePricingDto
{
    public int Id { get; set; }

    public int ServiceId { get; set; }

    public int? CityId { get; set; }

    public decimal VisitFee { get; set; }

    public decimal? MinimumPrice { get; set; }

    public decimal? MaximumPrice { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }
}