using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ServiceCategoryService : IServiceCategoryService
{
    private readonly ServiceCategoryRepository _repository;

    public ServiceCategoryService(ServiceCategoryRepository repository)
    {
        _repository = repository;
    }

    public Task<List<ServiceCategory>> GetActiveCategoriesAsync()
        => _repository.GetActiveAsync();

    public Task<ServiceCategory?> GetActiveCategoryByIdAsync(int id)
        => _repository.GetActiveByIdAsync(id);
}
