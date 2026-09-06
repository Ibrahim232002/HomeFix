using System.Security.Claims;
using HomeFix.API.Controllers;
using HomeFix.API.DTOs.Address;
using HomeFix.API.DTOs.ServiceRequest;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace HomeFix.Tests;

public class AddressAndServiceRequestIntegrityTests
{
    [Fact]
    public async Task CreateAddress_RejectsMismatchedCityAndGovernorate()
    {
        var addresses = new FakeAddressService
        {
            LocationValidationError = "City does not belong to the selected governorate."
        };
        var controller = new AddressesController(addresses, new FakeCustomerProfileService());
        SetCustomer(controller);

        var result = await controller.Create(new CreateAddressRequest
        {
            FullAddress = "Test address",
            GovernorateId = 1,
            CityId = 2
        });

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Contains("City does not belong to the selected governorate.", badRequest.Value!.ToString());
        Assert.False(addresses.AddCalled);
    }

    [Fact]
    public async Task UpdateAddress_RejectsMismatchedCityAndGovernorate()
    {
        var addresses = new FakeAddressService
        {
            ExistingAddress = new Address
            {
                Id = 5,
                CustomerId = 10,
                FullAddress = "Existing",
                GovernorateId = 1,
                CityId = 1
            },
            LocationValidationError = "City does not belong to the selected governorate."
        };
        var controller = new AddressesController(addresses, new FakeCustomerProfileService());
        SetCustomer(controller);

        var result = await controller.Update(5, new UpdateAddressRequest
        {
            FullAddress = "Updated",
            GovernorateId = 2,
            CityId = 3
        });

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Contains("City does not belong to the selected governorate.", badRequest.Value!.ToString());
        Assert.False(addresses.UpdateCalled);
    }

    [Fact]
    public async Task UpdateServiceRequest_AllowsOpenRequest()
    {
        var requests = new FakeServiceRequestService
        {
            ExistingRequest = new ServiceRequest
            {
                Id = 7,
                CustomerId = 10,
                Status = "Open",
                Description = "Old"
            }
        };
        var controller = new ServiceRequestsController(
            requests,
            new FakeCustomerProfileService(),
            technicianProfiles: null!,
            addresses: null!,
            servicePricing: null!);
        SetCustomer(controller);

        var result = await controller.Update(7, new UpdateServiceRequestRequest
        {
            Description = "Updated"
        });

        Assert.IsType<OkObjectResult>(result);
        Assert.True(requests.UpdateCalled);
        Assert.Equal("Updated", requests.ExistingRequest!.Description);
    }

    [Fact]
    public async Task UpdateServiceRequest_RejectsOfferPending()
    {
        var requests = new FakeServiceRequestService
        {
            ExistingRequest = new ServiceRequest
            {
                Id = 7,
                CustomerId = 10,
                Status = "OfferPending",
                Description = "Old"
            }
        };
        var controller = new ServiceRequestsController(
            requests,
            new FakeCustomerProfileService(),
            technicianProfiles: null!,
            addresses: null!,
            servicePricing: null!);
        SetCustomer(controller);

        var result = await controller.Update(7, new UpdateServiceRequestRequest
        {
            Description = "Updated"
        });

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("only be edited while it is open", badRequest.Value!.ToString());
        Assert.False(requests.UpdateCalled);
    }

    private static void SetCustomer(ControllerBase controller)
    {
        var identity = new ClaimsIdentity(
            new[]
            {
                new Claim(ClaimTypes.NameIdentifier, "42"),
                new Claim(ClaimTypes.Role, "Customer")
            },
            "Test");

        controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(identity)
            }
        };
    }

    private sealed class FakeCustomerProfileService : ICustomerProfileService
    {
        public Task<CustomerProfile?> GetByIdAsync(int id)
            => Task.FromResult<CustomerProfile?>(new CustomerProfile { Id = 10, UserId = 42 });

        public Task<CustomerProfile?> GetByUserIdAsync(int userId)
            => Task.FromResult<CustomerProfile?>(userId == 42 ? new CustomerProfile { Id = 10, UserId = 42 } : null);

        public Task AddAsync(CustomerProfile profile) => Task.CompletedTask;
        public Task UpdateAsync(CustomerProfile profile) => Task.CompletedTask;
    }

    private sealed class FakeAddressService : IAddressService
    {
        public Address? ExistingAddress { get; set; }
        public string? LocationValidationError { get; set; }
        public bool AddCalled { get; private set; }
        public bool UpdateCalled { get; private set; }

        public Task<Address?> GetByIdAsync(int id) => Task.FromResult(ExistingAddress);
        public Task<List<Address>> GetByCustomerIdAsync(int customerId) => Task.FromResult(new List<Address>());
        public Task<bool> HasServiceRequestsAsync(int addressId) => Task.FromResult(false);
        public Task<string?> ValidateLocationAsync(int? governorateId, int? cityId) => Task.FromResult(LocationValidationError);
        public Task AddAsync(Address address) { AddCalled = true; return Task.CompletedTask; }
        public Task UpdateAsync(Address address) { UpdateCalled = true; return Task.CompletedTask; }
        public Task DeleteAsync(Address address) => Task.CompletedTask;
    }

    private sealed class FakeServiceRequestService : IServiceRequestService
    {
        public ServiceRequest? ExistingRequest { get; set; }
        public bool UpdateCalled { get; private set; }

        public Task<ServiceRequest?> GetByIdAsync(int id) => Task.FromResult(ExistingRequest);
        public Task<List<ServiceRequest>> GetByCustomerIdAsync(int customerId) => Task.FromResult(new List<ServiceRequest>());
        public Task<List<ServiceRequest>> GetByStatusAsync(string status) => Task.FromResult(new List<ServiceRequest>());
        public Task<List<ServiceRequest>> GetPendingForTechnicianAsync(int technicianId) => Task.FromResult(new List<ServiceRequest>());
        public Task CreateAsync(ServiceRequest request) => Task.CompletedTask;
        public Task UpdateAsync(ServiceRequest request) { UpdateCalled = true; return Task.CompletedTask; }
        public Task<(bool Success, string? Error, ServiceRequest? Request)> CancelAsync(int requestId, int customerProfileId)
            => Task.FromResult<(bool, string?, ServiceRequest?)>((false, null, null));
    }
}
