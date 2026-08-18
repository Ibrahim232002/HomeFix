using HomeFix.API.DTOs.ServiceCategories;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServiceCategoriesController : ControllerBase
{
    private readonly IServiceCategoryService _serviceCategoryService;

    public ServiceCategoriesController(IServiceCategoryService serviceCategoryService)
    {
        _serviceCategoryService = serviceCategoryService;
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<ActionResult<List<ServiceCategoryDto>>> GetAll()
    {
        var categories = await _serviceCategoryService.GetActiveCategoriesAsync();

        return Ok(categories.Select(MapToDto).ToList());
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceCategoryDto>> GetById(int id)
    {
        var category = await _serviceCategoryService.GetActiveCategoryByIdAsync(id);

        if (category == null)
            return NotFound();

        return Ok(MapToDto(category));
    }

    private static ServiceCategoryDto MapToDto(HomeFix.DAL.Entities.ServiceCategory category)
    {
        return new ServiceCategoryDto
        {
            Id = category.Id,
            Name = category.Name,
            Description = category.Description,
            ImageUrl = category.ImageUrl,
            IconName = category.IconName,
            IsActive = category.IsActive
        };
    }
}
