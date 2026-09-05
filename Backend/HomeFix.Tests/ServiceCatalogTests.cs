using HomeFix.API.Controllers;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace HomeFix.Tests;

public class ServiceCatalogTests
{
    [Fact]
    public async Task ActiveLookup_ReturnsActiveServiceOnly()
    {
        await using var context = CreateContext();
        context.Services.AddRange(
            new Service { Id = 1, Name = "Active service", IsActive = true },
            new Service { Id = 2, Name = "Inactive service", IsActive = false });
        await context.SaveChangesAsync();

        var repository = new ServiceRepository(context);

        var active = await repository.GetActiveByIdAsync(1);
        var inactive = await repository.GetActiveByIdAsync(2);
        var missing = await repository.GetActiveByIdAsync(999);

        Assert.NotNull(active);
        Assert.True(active!.IsActive);
        Assert.Null(inactive);
        Assert.Null(missing);
    }

    [Fact]
    public async Task GetById_RemainsAvailableForInternalAdministrativeLookups()
    {
        await using var context = CreateContext();
        var inactiveService = new Service { Id = 2, Name = "Inactive service", IsActive = false };
        context.Services.Add(inactiveService);
        await context.SaveChangesAsync();

        var repository = new ServiceRepository(context);

        var result = await repository.GetByIdAsync(2);

        Assert.NotNull(result);
        Assert.False(result!.IsActive);
    }

    [Fact]
    public async Task PublicGetById_ReturnsOkForActiveService()
    {
        var service = new Service { Id = 1, Name = "Active service", IsActive = true };
        var controller = new ServicesController(new FakeServiceService(activeById: service));

        var result = await controller.GetById(1);

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        Assert.NotNull(ok.Value);
    }

    [Fact]
    public async Task PublicGetById_Returns404ForInactiveService()
    {
        var controller = new ServicesController(new FakeServiceService(activeById: null));

        var result = await controller.GetById(2);

        Assert.IsType<NotFoundResult>(result.Result);
    }

    [Fact]
    public async Task PublicGetById_Returns404ForMissingService()
    {
        var controller = new ServicesController(new FakeServiceService(activeById: null));

        var result = await controller.GetById(999);

        Assert.IsType<NotFoundResult>(result.Result);
    }

    [Fact]
    public async Task PublicGetAll_PreservesActiveCatalogBehavior()
    {
        var active = new Service { Id = 1, Name = "Active service", IsActive = true };
        var controller = new ServicesController(new FakeServiceService(all: new[] { active }));

        var result = await controller.GetAll();

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var services = Assert.IsAssignableFrom<List<HomeFix.API.DTOs.Services.ServiceDto>>(ok.Value);
        var returned = Assert.Single(services);
        Assert.Equal(1, returned.Id);
    }

    [Fact]
    public async Task PublicGetByCategory_PreservesActiveCatalogBehavior()
    {
        var active = new Service { Id = 1, Name = "Active service", IsActive = true };
        var controller = new ServicesController(new FakeServiceService(activeByCategory: new[] { active }));

        var result = await controller.GetByCategory(1);

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var services = Assert.IsAssignableFrom<List<HomeFix.API.DTOs.Services.ServiceDto>>(ok.Value);
        var returned = Assert.Single(services);
        Assert.Equal(1, returned.Id);
    }

    private static HomeFixDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<HomeFixDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new HomeFixDbContext(options);
    }

    private sealed class FakeServiceService : IServiceService
    {
        private readonly Service? _activeById;
        private readonly IReadOnlyList<Service> _all;
        private readonly IReadOnlyList<Service> _activeByCategory;

        public FakeServiceService(
            Service? activeById = null,
            IEnumerable<Service>? all = null,
            IEnumerable<Service>? activeByCategory = null)
        {
            _activeById = activeById;
            _all = all?.ToList() ?? [];
            _activeByCategory = activeByCategory?.ToList() ?? [];
        }

        public Task<List<Service>> GetAllServicesAsync() => Task.FromResult(_all.ToList());

        public Task<Service?> GetServiceByIdAsync(int id)
            => Task.FromResult(_all.FirstOrDefault(service => service.Id == id));

        public Task<Service?> GetActiveServiceByIdAsync(int id)
            => Task.FromResult(_activeById?.Id == id ? _activeById : null);

        public Task<List<Service>> GetActiveServicesByCategoryAsync(int categoryId)
            => Task.FromResult(_activeByCategory.ToList());
    }
}
