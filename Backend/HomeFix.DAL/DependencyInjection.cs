using HomeFix.DAL.Data;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace HomeFix.DAL;

public static class DependencyInjection
{
    public static IServiceCollection AddHomeFixDAL(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<HomeFixDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<UnitOfWork>();

        services.AddScoped<UserRepository>();
        services.AddScoped<CustomerProfileRepository>();
        services.AddScoped<TechnicianProfileRepository>();

        services.AddScoped<GovernorateRepository>();
        services.AddScoped<CityRepository>();
        services.AddScoped<AddressRepository>();

        services.AddScoped<ServiceRepository>();
        services.AddScoped<ServicePricingRepository>();

        services.AddScoped<ServiceRequestRepository>();
        services.AddScoped<ServiceRequestFileRepository>();
        services.AddScoped<ServiceRequestStatusHistoryRepository>();

        services.AddScoped<BookingRepository>();
        services.AddScoped<ReviewRepository>();
        services.AddScoped<PaymentRepository>();
        services.AddScoped<PayoutRepository>();

        services.AddScoped<TechnicianAvailabilityRepository>();
        services.AddScoped<TechnicianDocumentRepository>();
        services.AddScoped<TechnicianServiceAreaRepository>();
        services.AddScoped<TechnicianWalletRepository>();
        services.AddScoped<WalletTransactionRepository>();

        services.AddScoped<ConversationRepository>();
        services.AddScoped<MessageRepository>();
        services.AddScoped<NotificationRepository>();

        services.AddScoped<SupportTicketRepository>();
        services.AddScoped<SupportMessageRepository>();

        services.AddScoped<PromoCodeRepository>();
        services.AddScoped<UserPromoCodeRepository>();

        services.AddScoped<RefreshTokenRepository>();
        services.AddScoped<EmailVerificationTokenRepository>();
        services.AddScoped<PasswordResetTokenRepository>();

        services.AddScoped<VerificationCodeRepository>();
        services.AddScoped<ExternalLoginRepository>();
        services.AddScoped<UserDeviceRepository>();
        services.AddScoped<ServiceRequestOfferRepository>();
        services.AddScoped<PaymentAttemptRepository>();

        return services;
    }
}