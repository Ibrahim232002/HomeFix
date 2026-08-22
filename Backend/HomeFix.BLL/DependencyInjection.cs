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
        services.AddScoped<VerificationCodeRepository>();
        services.AddScoped<ExternalLoginRepository>();
        services.AddScoped<UserDeviceRepository>();
        services.AddScoped<ServiceRequestOfferRepository>();
        services.AddScoped<PaymentAttemptRepository>();
        services.AddScoped<InspectionRepository>();

        services.AddScoped<IUserService, UserService>();
        services.AddScoped<ICustomerProfileService, CustomerProfileService>();
        services.AddScoped<ITechnicianProfileService, TechnicianProfileService>();

        services.AddScoped<IGovernorateService, GovernorateService>();
        services.AddScoped<ICityService, CityService>();
        services.AddScoped<IAddressService, AddressService>();

        services.AddScoped<IServiceService, ServiceService>();
        services.AddScoped<IServiceCategoryService, ServiceCategoryService>();
        services.AddScoped<IServicePricingService, ServicePricingService>();

        services.AddScoped<IServiceRequestService, ServiceRequestService>();
        services.AddScoped<IServiceRequestOfferService, ServiceRequestOfferService>();
        services.AddScoped<IServiceRequestFileService, ServiceRequestFileService>();
        services.AddScoped<IServiceRequestStatusHistoryService, ServiceRequestStatusHistoryService>();
        services.AddScoped<IInspectionService, InspectionService>();

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

        services.AddOptions<GoogleSettings>()
            .Bind(configuration.GetSection("Google"));

        services.AddOptions<EmailSettings>()
            .Bind(configuration.GetSection("Email"));

        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IVerificationCodeService, VerificationCodeService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IUserDeviceService, UserDeviceService>();

        return services;
    }
}
