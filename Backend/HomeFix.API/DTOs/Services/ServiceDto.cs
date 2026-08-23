using HomeFix.DAL.Enums;

namespace HomeFix.API.DTOs.Services;

public class ServiceDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int CategoryId { get; set; }
    public PricingMode PricingMode { get; set; }
    public bool IsActive { get; set; }
}
