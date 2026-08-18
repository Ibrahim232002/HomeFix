namespace HomeFix.API.DTOs.ServiceCategories;

public class ServiceCategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public string? IconName { get; set; }
    public bool IsActive { get; set; }
}
