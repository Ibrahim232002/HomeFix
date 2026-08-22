using System;
using System.Collections.Generic;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Data;

public partial class HomeFixDbContext : DbContext
{
    public HomeFixDbContext()
    {
    }

    public HomeFixDbContext(DbContextOptions<HomeFixDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Address> Addresses { get; set; }

    public virtual DbSet<Booking> Bookings { get; set; }

    public virtual DbSet<City> Cities { get; set; }

    public virtual DbSet<Conversation> Conversations { get; set; }

    public virtual DbSet<CustomerProfile> CustomerProfiles { get; set; }

    public virtual DbSet<EmailVerificationToken> EmailVerificationTokens { get; set; }

    public virtual DbSet<Governorate> Governorates { get; set; }

    public virtual DbSet<Message> Messages { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<PasswordResetToken> PasswordResetTokens { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Payout> Payouts { get; set; }

    public virtual DbSet<PromoCode> PromoCodes { get; set; }

    public virtual DbSet<RefreshToken> RefreshTokens { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Service> Services { get; set; }

    public virtual DbSet<ServicePricing> ServicePricings { get; set; }

    public virtual DbSet<ServiceRequest> ServiceRequests { get; set; }

    public virtual DbSet<ServiceRequestFile> ServiceRequestFiles { get; set; }

    public virtual DbSet<ServiceRequestStatusHistory> ServiceRequestStatusHistories { get; set; }

    public virtual DbSet<SupportMessage> SupportMessages { get; set; }

    public virtual DbSet<SupportTicket> SupportTickets { get; set; }

    public virtual DbSet<TechnicianAvailability> TechnicianAvailabilities { get; set; }

    public virtual DbSet<TechnicianDocument> TechnicianDocuments { get; set; }

    public virtual DbSet<TechnicianProfile> TechnicianProfiles { get; set; }

    public virtual DbSet<TechnicianServiceArea> TechnicianServiceAreas { get; set; }

    public virtual DbSet<TechnicianWallet> TechnicianWallets { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserPromoCode> UserPromoCodes { get; set; }

    public virtual DbSet<WalletTransaction> WalletTransactions { get; set; }

    public virtual DbSet<VerificationCode> VerificationCodes { get; set; }

    public virtual DbSet<ExternalLogin> ExternalLogins { get; set; }

    public virtual DbSet<UserDevice> UserDevices { get; set; }

    public virtual DbSet<ServiceRequestOffer> ServiceRequestOffers { get; set; }

    public virtual DbSet<PaymentAttempt> PaymentAttempts { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Address>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Addresse__3214EC0709D40DC6");

            entity.Property(e => e.AdditionalInstructions).HasMaxLength(1000);
            entity.Property(e => e.ApartmentNumber).HasMaxLength(20);
            entity.Property(e => e.BuildingNumber).HasMaxLength(20);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.FloorNumber).HasMaxLength(20);
            entity.Property(e => e.FullAddress).HasMaxLength(500);
            entity.Property(e => e.Label).HasMaxLength(50);
            entity.Property(e => e.Latitude).HasColumnType("decimal(10, 7)");
            entity.Property(e => e.Longitude).HasColumnType("decimal(10, 7)");

            entity.HasOne(d => d.Customer).WithMany(p => p.Addresses)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Addresses_Customer");

            entity.HasOne(d => d.Governorate).WithMany(p => p.Addresses)
                .HasForeignKey(d => d.GovernorateId)
                .HasConstraintName("FK_Addresses_Governorates");

            entity.HasOne(d => d.City).WithMany(p => p.Addresses)
                .HasPrincipalKey(p => new { p.Id, p.GovernorateId })
                .HasForeignKey(d => new { d.CityId, d.GovernorateId })
                .HasConstraintName("FK_Addresses_City_Governorate");
        });

        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Bookings__3214EC074E5289A3");

            entity.HasIndex(e => e.ServiceRequestId, "UQ__Bookings__790F6C8A34F866A4").IsUnique();

            entity.Property(e => e.AgreedPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.FinalPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Confirmed");
            entity.Property(e => e.TechnicianNotes).HasMaxLength(2000);

            entity.HasOne(d => d.ServiceRequest).WithOne(p => p.Booking)
                .HasForeignKey<Booking>(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Bookings_Request");

            entity.HasOne(d => d.Technician).WithMany(p => p.Bookings)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Bookings_Technician");
        });

        modelBuilder.Entity<City>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Cities__3214EC07D979D179");

            entity.HasIndex(e => new { e.GovernorateId, e.Name }, "UQ_Cities_Governorate_Name").IsUnique();

            entity.HasIndex(e => new { e.Id, e.GovernorateId }, "UQ_Cities_Id_Governorate").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);

            entity.HasOne(d => d.Governorate).WithMany(p => p.Cities)
                .HasForeignKey(d => d.GovernorateId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Cities_Governorates");
        });

        modelBuilder.Entity<Conversation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Conversa__3214EC07B007718E");

            entity.HasIndex(e => e.ServiceRequestId, "UQ__Conversa__790F6C8A898F216E").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Customer).WithMany(p => p.Conversations)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Conversations_Customer");

            entity.HasOne(d => d.ServiceRequest).WithOne(p => p.Conversation)
                .HasForeignKey<Conversation>(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Conversations_ServiceRequest");

            entity.HasOne(d => d.Technician).WithMany(p => p.Conversations)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Conversations_Technician");
        });

        modelBuilder.Entity<CustomerProfile>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Customer__3214EC0717000FE5");

            entity.HasIndex(e => e.UserId, "UQ__Customer__1788CC4D4EA9CC72").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.ProfileImageUrl).HasMaxLength(500);

            entity.HasOne(d => d.User).WithOne(p => p.CustomerProfile)
                .HasForeignKey<CustomerProfile>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CustomerProfiles_Users");
        });

        modelBuilder.Entity<EmailVerificationToken>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__EmailVer__3214EC07E018C616");

            entity.HasIndex(e => e.Token, "UQ__EmailVer__1EB4F817C701AAD0").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Token).HasMaxLength(500);

            entity.HasOne(d => d.User).WithMany(p => p.EmailVerificationTokens)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_EmailVerificationTokens_User");
        });

        modelBuilder.Entity<Governorate>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Governor__3214EC0780365915");

            entity.HasIndex(e => e.Name, "UQ__Governor__737584F6D9D82374").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Message>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Messages__3214EC078A6F6236");

            entity.Property(e => e.AttachmentType).HasMaxLength(20);
            entity.Property(e => e.AttachmentUrl).HasMaxLength(500);
            entity.Property(e => e.MessageText).HasMaxLength(2000);
            entity.Property(e => e.SentAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Conversation).WithMany(p => p.Messages)
                .HasForeignKey(d => d.ConversationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Messages_Conversation");

            entity.HasOne(d => d.Sender).WithMany(p => p.Messages)
                .HasForeignKey(d => d.SenderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Messages_Sender");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Notifica__3214EC074C7ECD46");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Message).HasMaxLength(1000);
            entity.Property(e => e.ReferenceId);
            entity.Property(e => e.Title).HasMaxLength(200);
            entity.Property(e => e.Type).HasMaxLength(50);

            entity.HasOne(d => d.User).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Notifications_User");
        });

        modelBuilder.Entity<PasswordResetToken>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Password__3214EC07706FD9D2");

            entity.HasIndex(e => e.Token, "UQ__Password__1EB4F81771672048").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Token).HasMaxLength(500);

            entity.HasOne(d => d.User).WithMany(p => p.PasswordResetTokens)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PasswordResetTokens_User");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Payments__3214EC07E975531E");

            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.PaymentMethod).HasMaxLength(30);
            entity.Property(e => e.PaymentType).HasMaxLength(30);
            entity.Property(e => e.Provider).HasMaxLength(50);
            entity.Property(e => e.ProviderTransactionId).HasMaxLength(200);
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Pending");
            entity.Property(e => e.TransactionReference).HasMaxLength(200);

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.Payments)
                .HasForeignKey(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Payments_Request");
        });

        modelBuilder.Entity<Payout>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Payouts__3214EC0754E7C32B");

            entity.Property(e => e.Amount).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.PaymentMethod).HasMaxLength(30);
            entity.Property(e => e.RequestedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Pending");
            entity.Property(e => e.TransactionReference).HasMaxLength(200);

            entity.HasOne(d => d.Technician).WithMany(p => p.Payouts)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Payouts_Technician");
        });

        modelBuilder.Entity<PromoCode>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__PromoCod__3214EC07A0FDBFD9");

            entity.HasIndex(e => e.Code, "UQ__PromoCod__A25C5AA7AEEF8AB8").IsUnique();

            entity.Property(e => e.Code).HasMaxLength(50);
            entity.Property(e => e.DiscountType).HasMaxLength(20);
            entity.Property(e => e.DiscountValue).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__RefreshT__3214EC0735665D94");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsRevoked)
                .HasComputedColumnSql(
                    "(CONVERT([bit],case when [RevokedAt] IS NULL then (0) else (1) end))",
                    true);
            entity.Property(e => e.TokenHash)
                .IsRequired()
                .HasMaxLength(128);
            entity.HasIndex(e => e.TokenHash)
                .HasDatabaseName("UX_RefreshTokens_TokenHash")
                .IsUnique();

            entity.HasOne(d => d.User).WithMany(p => p.RefreshTokens)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefreshTokens_User");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reviews__3214EC07A804FF76");

            entity.HasIndex(e => e.ServiceRequestId, "UQ__Reviews__790F6C8A5AF653A1").IsUnique();

            entity.Property(e => e.Comment).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Customer).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Customer");

            entity.HasOne(d => d.ServiceRequest).WithOne(p => p.Review)
                .HasForeignKey<Review>(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Request");

            entity.HasOne(d => d.Technician).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Technician");
        });

        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Services__3214EC07AD91B341");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.EstimatedDurationMinutes);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<ServicePricing>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ServiceP__3214EC073F5EC95C");

            entity.ToTable("ServicePricing");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.MaximumPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.MinimumPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.VisitFee).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.InspectionFee).HasColumnType("decimal(10, 2)");

            entity.HasIndex(e => new { e.ServiceId, e.CityId })
                .HasDatabaseName("UX_ServicePricing_Active_Service_City")
                .IsUnique()
                .HasFilter("[IsActive] = 1 AND [CityId] IS NOT NULL");

            entity.HasIndex(e => e.ServiceId)
                .HasDatabaseName("UX_ServicePricing_Active_Service_Global")
                .IsUnique()
                .HasFilter("[IsActive] = 1 AND [CityId] IS NULL");

            entity.HasOne(d => d.City).WithMany(p => p.ServicePricings)
                .HasForeignKey(d => d.CityId)
                .HasConstraintName("FK_ServicePricing_City");

            entity.HasOne(d => d.Service).WithMany(p => p.ServicePricings)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServicePricing_Service");
        });

        modelBuilder.Entity<ServiceRequest>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ServiceR__3214EC077231B44C");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Description).HasMaxLength(2000);
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Pending");
            entity.Property(e => e.VisitFee).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Address).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.AddressId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequests_Address");

            entity.HasOne(d => d.Customer).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequests_Customer");

            entity.HasOne(d => d.Service).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequests_Service");
        });

        modelBuilder.Entity<ServiceRequestFile>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ServiceR__3214EC0714E20FA2");

            entity.Property(e => e.FileType)
                .HasMaxLength(20)
                .HasDefaultValue("Image");
            entity.Property(e => e.FileUrl).HasMaxLength(500);
            entity.Property(e => e.UploadedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.ServiceRequestFiles)
                .HasForeignKey(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequestImages_Request");
        });

        modelBuilder.Entity<ServiceRequestStatusHistory>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ServiceR__3214EC071F6475A8");

            entity.ToTable("ServiceRequestStatusHistory");

            entity.Property(e => e.ChangedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.NewStatus).HasMaxLength(30);
            entity.Property(e => e.OldStatus).HasMaxLength(30);

            entity.HasOne(d => d.ChangedByUser).WithMany(p => p.ServiceRequestStatusHistories)
                .HasForeignKey(d => d.ChangedByUserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_StatusHistory_User");

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.ServiceRequestStatusHistories)
                .HasForeignKey(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_StatusHistory_ServiceRequest");
        });

        modelBuilder.Entity<SupportMessage>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__SupportM__3214EC0778607336");

            entity.Property(e => e.AttachmentUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Message).HasMaxLength(2000);

            entity.HasOne(d => d.Sender).WithMany(p => p.SupportMessages)
                .HasForeignKey(d => d.SenderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SupportMessages_Sender");

            entity.HasOne(d => d.SupportTicket).WithMany(p => p.SupportMessages)
                .HasForeignKey(d => d.SupportTicketId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SupportMessages_Ticket");
        });

        modelBuilder.Entity<SupportTicket>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__SupportT__3214EC07D37A6F74");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Description).HasMaxLength(2000);
            entity.Property(e => e.Priority)
                .HasMaxLength(20)
                .HasDefaultValue("Medium");
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Open");
            entity.Property(e => e.Subject).HasMaxLength(200);

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.SupportTickets)
                .HasForeignKey(d => d.ServiceRequestId)
                .HasConstraintName("FK_SupportTickets_ServiceRequest");

            entity.HasOne(d => d.User).WithMany(p => p.SupportTickets)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SupportTickets_User");
        });

        modelBuilder.Entity<TechnicianAvailability>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Technici__3214EC079610404C");

            entity.ToTable("TechnicianAvailability");

            entity.Property(e => e.IsAvailable).HasDefaultValue(true);

            entity.HasOne(d => d.Technician).WithMany(p => p.TechnicianAvailabilities)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianAvailability_Technician");
        });

        modelBuilder.Entity<TechnicianDocument>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Technici__3214EC07D3A1F2B4");

            entity.Property(e => e.DocumentType).HasMaxLength(50);
            entity.Property(e => e.DocumentUrl).HasMaxLength(500);
            entity.Property(e => e.RejectionReason).HasMaxLength(500);
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .HasDefaultValue("Pending");
            entity.Property(e => e.UploadedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Technician).WithMany(p => p.TechnicianDocuments)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianDocuments_Technician");
        });

        modelBuilder.Entity<TechnicianProfile>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Technici__3214EC07F1E9D07A");

            entity.HasIndex(e => e.UserId, "UQ__Technici__1788CC4DC4C75A2C").IsUnique();

            entity.Property(e => e.AverageRating).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.Bio).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.CurrentLatitude).HasColumnType("decimal(10, 7)");
            entity.Property(e => e.CurrentLongitude).HasColumnType("decimal(10, 7)");
            entity.Property(e => e.ProfileImageUrl).HasMaxLength(500);

            entity.HasOne(d => d.CurrentGovernorate)
                .WithMany()
                .HasForeignKey(d => d.CurrentGovernorateId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianProfiles_CurrentGovernorate");

            entity.HasOne(d => d.CurrentCity)
                .WithMany()
                .HasForeignKey(d => d.CurrentCityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianProfiles_CurrentCity");

            entity.HasOne(d => d.User).WithOne(p => p.TechnicianProfile)
                .HasForeignKey<TechnicianProfile>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianProfiles_Users");

            entity.HasMany(d => d.Services).WithMany(p => p.Technicians)
                .UsingEntity<Dictionary<string, object>>(
                    "TechnicianService",
                    r => r.HasOne<Service>().WithMany()
                        .HasForeignKey("ServiceId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_TechnicianServices_Service"),
                    l => l.HasOne<TechnicianProfile>().WithMany()
                        .HasForeignKey("TechnicianId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_TechnicianServices_Technician"),
                    j =>
                    {
                        j.HasKey("TechnicianId", "ServiceId");
                        j.ToTable("TechnicianServices");
                    });
        });

        modelBuilder.Entity<TechnicianServiceArea>(entity =>
        {
            entity.HasKey(e => new { e.TechnicianId, e.CityId });

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.City).WithMany(p => p.TechnicianServiceAreas)
                .HasForeignKey(d => d.CityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianServiceAreas_City");

            entity.HasOne(d => d.Technician).WithMany(p => p.TechnicianServiceAreas)
                .HasForeignKey(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianServiceAreas_Technician");
        });

        modelBuilder.Entity<TechnicianWallet>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Technici__3214EC071D2EC1BE");

            entity.HasIndex(e => e.TechnicianId, "UQ__Technici__301F812009726F2F").IsUnique();

            entity.Property(e => e.Balance).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Technician).WithOne(p => p.TechnicianWallet)
                .HasForeignKey<TechnicianWallet>(d => d.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianWallets_Technician");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Users__3214EC077DC7C201");

            entity.HasIndex(e => e.PhoneNumber, "UQ__Users__85FB4E38F617F54B").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Users__A9D10534097A4A1C").IsUnique();

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.IsPhoneVerified).HasDefaultValue(false);
            entity.Property(e => e.PasswordHash).HasMaxLength(500);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Role).HasMaxLength(20);
        });

        modelBuilder.Entity<UserPromoCode>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__UserProm__3214EC079CC9A3B0");

            entity.HasIndex(e => e.ServiceRequestId, "UQ_UserPromoCodes_Request").IsUnique();

            entity.Property(e => e.DiscountAmount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UsedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.PromoCode).WithMany(p => p.UserPromoCodes)
                .HasForeignKey(d => d.PromoCodeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserPromoCodes_PromoCode");

            entity.HasOne(d => d.ServiceRequest).WithOne(p => p.UserPromoCode)
                .HasForeignKey<UserPromoCode>(d => d.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserPromoCodes_ServiceRequest");

            entity.HasOne(d => d.User).WithMany(p => p.UserPromoCodes)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserPromoCodes_User");
        });

        modelBuilder.Entity<WalletTransaction>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__WalletTr__3214EC078EB50875");

            entity.Property(e => e.Amount).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.BalanceAfter).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.BalanceBefore).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.TransactionType).HasMaxLength(30);

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.WalletTransactions)
                .HasForeignKey(d => d.ServiceRequestId)
                .HasConstraintName("FK_WalletTransactions_ServiceRequest");

            entity.HasOne(d => d.Wallet).WithMany(p => p.WalletTransactions)
                .HasForeignKey(d => d.WalletId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WalletTransactions_Wallet");
        });

        modelBuilder.Entity<VerificationCode>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => new { e.UserId, e.Purpose, e.Channel, e.CreatedAt });
            entity.HasIndex(e => new { e.BookingId, e.Purpose, e.UsedAt });

            entity.Property(e => e.CodeHash).HasMaxLength(128);
            entity.Property(e => e.Purpose).HasMaxLength(50);
            entity.Property(e => e.Channel).HasMaxLength(20);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Attempts).HasDefaultValue(0);

            entity.HasOne(e => e.User)
                .WithMany(u => u.VerificationCodes)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_VerificationCodes_User");

            entity.HasOne(e => e.Booking)
                .WithMany(b => b.VerificationCodes)
                .HasForeignKey(e => e.BookingId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_VerificationCodes_Booking");
        });

        modelBuilder.Entity<ExternalLogin>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => new { e.Provider, e.ProviderSubjectId })
                .IsUnique()
                .HasDatabaseName("UX_ExternalLogins_Provider_Subject");

            entity.Property(e => e.Provider).HasMaxLength(30);
            entity.Property(e => e.ProviderSubjectId).HasMaxLength(200);
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(e => e.User)
                .WithMany(u => u.ExternalLogins)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ExternalLogins_User");
        });

        modelBuilder.Entity<UserDevice>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => e.DeviceToken)
                .IsUnique()
                .HasDatabaseName("UX_UserDevices_DeviceToken");

            entity.HasIndex(e => new { e.UserId, e.IsActive });

            entity.Property(e => e.DeviceToken).HasMaxLength(500);
            entity.Property(e => e.Platform).HasMaxLength(20);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(e => e.User)
                .WithMany(p => p.UserDevices)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserDevices_User");
        });

        modelBuilder.Entity<ServiceRequestOffer>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => new { e.ServiceRequestId, e.Status });
            entity.HasIndex(e => new { e.TechnicianId, e.Status });
            entity.HasIndex(e => e.ServiceRequestId)
                .HasDatabaseName("UX_ServiceRequestOffers_OneAccepted")
                .IsUnique()
                .HasFilter("[Status] = 'Accepted'");

            entity.Property(e => e.ProposedPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Pending");
            entity.Property(e => e.TechnicianNote).HasMaxLength(2000);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(e => e.ServiceRequest)
                .WithMany(r => r.ServiceRequestOffers)
                .HasForeignKey(e => e.ServiceRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequestOffers_ServiceRequest");

            entity.HasOne(e => e.Technician)
                .WithMany(t => t.ServiceRequestOffers)
                .HasForeignKey(e => e.TechnicianId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ServiceRequestOffers_Technician");
        });

        modelBuilder.Entity<PaymentAttempt>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => e.PaymentId);
            entity.HasIndex(e => e.ProviderTransactionId)
                .IsUnique()
                .HasDatabaseName("UX_PaymentAttempts_ProviderTransactionId")
                .HasFilter("[ProviderTransactionId] IS NOT NULL");

            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Provider).HasMaxLength(50);
            entity.Property(e => e.ProviderTransactionId).HasMaxLength(200);
            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Pending");
            entity.Property(e => e.FailureReason).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(e => e.Payment)
                .WithMany(p => p.PaymentAttempts)
                .HasForeignKey(e => e.PaymentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PaymentAttempts_Payment");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
