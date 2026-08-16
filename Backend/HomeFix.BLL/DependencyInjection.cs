using HomeFix.BLL.Interfaces;
using HomeFix.BLL.Models;
using HomeFix.BLL.Services;
using HomeFix.DAL;
using HomeFix.DAL.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace HomeFix.BLL;

public static class DependencyInjection
{
    public static IServiceCollection AddHomeFixBLL(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddHomeFixDAL(configuration);

        services.AddScoped<UserRepository>();
        services.AddScoped<RefreshTokenRepository>();

        services.AddScoped<IUserService, UserService>();
        services.AddScoped<ICustomerProfileService, CustomerProfileService>();
        services.AddScoped<ITechnicianProfileService, TechnicianProfileService>();

        services.AddScoped<IGovernorateService, GovernorateService>();
        services.AddScoped<ICityService, CityService>();
        services.AddScoped<IAddressService, AddressService>();

        services.AddScoped<IServiceService, ServiceService>();
        services.AddScoped<IServicePricingService, ServicePricingService>();

        services.AddScoped<IServiceRequestService, ServiceRequestService>();
        services.AddScoped<IServiceRequestFileService, ServiceRequestFileService>();
        services.AddScoped<IServiceRequestStatusHistoryService, ServiceRequestStatusHistoryService>();

        services.AddScoped<IBookingService, BookingService>();
        services.AddScoped<IReviewService, ReviewService>();

        services.AddScoped<IPaymentService, PaymentService>();
        services.AddScoped<IPayoutService, PayoutService>();

        services.AddScoped<ITechnicianAvailabilityService, TechnicianAvailabilityService>();
        services.AddScoped<ITechnicianDocumentService, TechnicianDocumentService>();
        services.AddScoped<ITechnicianServiceAreaService, TechnicianServiceAreaService>();
        services.AddScoped<ITechnicianWalletService, TechnicianWalletService>();
        services.AddScoped<IWalletTransactionService, WalletTransactionService>();

        services.AddScoped<IConversationService, ConversationService>();
        services.AddScoped<IMessageService, MessageService>();
        services.AddScoped<INotificationService, NotificationService>();

        services.AddScoped<ISupportTicketService, SupportTicketService>();
        services.AddScoped<ISupportMessageService, SupportMessageService>();

        services.AddScoped<IPromoCodeService, PromoCodeService>();
        services.AddScoped<IUserPromoCodeService, UserPromoCodeService>();

        services.AddScoped<IRefreshTokenService, RefreshTokenService>();
        services.AddScoped<IEmailVerificationTokenService, EmailVerificationTokenService>();
        services.AddScoped<IPasswordResetTokenService, PasswordResetTokenService>();

        services.AddOptions<JwtSettings>()
            .Bind(configuration.GetSection("Jwt"));

        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IAuthService, AuthService>();

        return services;
    }
}