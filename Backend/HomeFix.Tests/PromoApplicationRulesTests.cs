using HomeFix.BLL.Services;
using HomeFix.DAL.Entities;
using Xunit;

namespace HomeFix.Tests;

public class PromoApplicationRulesTests
{
    [Fact]
    public void UnauthorizedCustomer_CannotApplyPromoToAnotherCustomersRequest()
    {
        var request = new ServiceRequest
        {
            CustomerId = 10,
            Customer = new CustomerProfile { UserId = 42 }
        };

        Assert.False(PromoApplicationRules.BelongsToAuthenticatedCustomer(request, authenticatedUserId: 99));
    }

    [Fact]
    public void AuthenticatedCustomer_CanApplyPromoToOwnRequest()
    {
        var request = new ServiceRequest
        {
            CustomerId = 10,
            Customer = new CustomerProfile { UserId = 42 }
        };

        Assert.True(PromoApplicationRules.BelongsToAuthenticatedCustomer(request, authenticatedUserId: 42));
    }

    [Fact]
    public void ExistingPromoApplication_BlocksDuplicateApplication()
    {
        var existing = new UserPromoCode { Id = 5, ServiceRequestId = 10 };

        Assert.True(PromoApplicationRules.HasExistingApplication(existing));
        Assert.False(PromoApplicationRules.HasExistingApplication(null));
    }
}