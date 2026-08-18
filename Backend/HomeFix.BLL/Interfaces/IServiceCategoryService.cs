using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceCategoryService
{
    Task<List<ServiceCategory>> GetActiveCategoriesAsync();
    Task<ServiceCategory?> GetActiveCategoryByIdAsync(int id);
}
