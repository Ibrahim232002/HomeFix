using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Services;

public static class PromoApplicationRules
{
    public static bool BelongsToAuthenticatedCustomer(ServiceRequest request, int authenticatedUserId)
        => request.Customer?.UserId == authenticatedUserId;

    public static bool HasExistingApplication(UserPromoCode? existing)
        => existing is not null;
}