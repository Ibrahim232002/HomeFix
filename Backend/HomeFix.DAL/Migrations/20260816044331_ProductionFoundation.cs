using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations
{
    /// <inheritdoc />
    public partial class ProductionFoundation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Governorates",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Governor__3214EC0780365915", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PromoCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    DiscountType = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    DiscountValue = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    MaxUses = table.Column<int>(type: "int", nullable: true),
                    UsedCount = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PromoCod__3214EC07A0FDBFD9", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Services",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    EstimatedDurationMinutes = table.Column<int>(type: "int", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Services__3214EC07AD91B341", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FullName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Role = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    IsEmailVerified = table.Column<bool>(type: "bit", nullable: false),
                    IsPhoneVerified = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Users__3214EC077DC7C201", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    GovernorateId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Cities__3214EC07D979D179", x => x.Id);
                    table.UniqueConstraint("AK_Cities_Id_GovernorateId", x => new { x.Id, x.GovernorateId });
                    table.ForeignKey(
                        name: "FK_Cities_Governorates",
                        column: x => x.GovernorateId,
                        principalTable: "Governorates",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "CustomerProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ProfileImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Customer__3214EC0717000FE5", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomerProfiles_Users",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "EmailVerificationTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Token = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__EmailVer__3214EC07E018C616", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EmailVerificationTokens_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ExternalLogins",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Provider = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    ProviderSubjectId = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExternalLogins", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ExternalLogins_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Message = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    Type = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    ReferenceId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Notifica__3214EC074C7ECD46", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PasswordResetTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Token = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Password__3214EC07706FD9D2", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PasswordResetTokens_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Token = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    TokenHash = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    RevokedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsRevoked = table.Column<bool>(type: "bit", nullable: true, computedColumnSql: "(CONVERT([bit],case when [RevokedAt] IS NULL then (0) else (1) end))", stored: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__RefreshT__3214EC0735665D94", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Bio = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    ProfileImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    YearsOfExperience = table.Column<int>(type: "int", nullable: true),
                    IsVerified = table.Column<bool>(type: "bit", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false),
                    AverageRating = table.Column<decimal>(type: "decimal(3,2)", nullable: false),
                    TotalJobs = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    CurrentLatitude = table.Column<decimal>(type: "decimal(10,7)", nullable: true),
                    CurrentLongitude = table.Column<decimal>(type: "decimal(10,7)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Technici__3214EC07F1E9D07A", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechnicianProfiles_Users",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserDevices",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    DeviceToken = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Platform = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    LastSeenAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserDevices", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserDevices_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ServicePricing",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: true),
                    VisitFee = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    MinimumPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    MaximumPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ServiceP__3214EC073F5EC95C", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ServicePricing_City",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ServicePricing_Service",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Addresses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CustomerId = table.Column<int>(type: "int", nullable: false),
                    Label = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    FullAddress = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Latitude = table.Column<decimal>(type: "decimal(10,7)", nullable: true),
                    Longitude = table.Column<decimal>(type: "decimal(10,7)", nullable: true),
                    BuildingNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    FloorNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    ApartmentNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    AdditionalInstructions = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsDefault = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    GovernorateId = table.Column<int>(type: "int", nullable: true),
                    CityId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Addresse__3214EC0709D40DC6", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Addresses_City_Governorate",
                        columns: x => new { x.CityId, x.GovernorateId },
                        principalTable: "Cities",
                        principalColumns: new[] { "Id", "GovernorateId" });
                    table.ForeignKey(
                        name: "FK_Addresses_Customer",
                        column: x => x.CustomerId,
                        principalTable: "CustomerProfiles",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Addresses_Governorates",
                        column: x => x.GovernorateId,
                        principalTable: "Governorates",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Payouts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(12,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Pending"),
                    PaymentMethod = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    TransactionReference = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    RequestedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Payouts__3214EC0754E7C32B", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payouts_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianAvailability",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    DayOfWeek = table.Column<byte>(type: "tinyint", nullable: false),
                    StartTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Technici__3214EC079610404C", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechnicianAvailability_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianDocuments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    DocumentType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    DocumentUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "Pending"),
                    RejectionReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Technici__3214EC07D3A1F2B4", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechnicianDocuments_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianServiceAreas",
                columns: table => new
                {
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechnicianServiceAreas", x => new { x.TechnicianId, x.CityId });
                    table.ForeignKey(
                        name: "FK_TechnicianServiceAreas_City",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TechnicianServiceAreas_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianServices",
                columns: table => new
                {
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    ServiceId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechnicianServices", x => new { x.TechnicianId, x.ServiceId });
                    table.ForeignKey(
                        name: "FK_TechnicianServices_Service",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TechnicianServices_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TechnicianWallets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    Balance = table.Column<decimal>(type: "decimal(12,2)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Technici__3214EC071D2EC1BE", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechnicianWallets_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ServiceRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CustomerId = table.Column<int>(type: "int", nullable: false),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    AddressId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    PreferredDate = table.Column<DateOnly>(type: "date", nullable: true),
                    PreferredTime = table.Column<TimeOnly>(type: "time", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Pending"),
                    VisitFee = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ServiceR__3214EC077231B44C", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ServiceRequests_Address",
                        column: x => x.AddressId,
                        principalTable: "Addresses",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ServiceRequests_Customer",
                        column: x => x.CustomerId,
                        principalTable: "CustomerProfiles",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ServiceRequests_Service",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Bookings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Confirmed"),
                    AgreedPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    AcceptedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ArrivedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    StartedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    FinalPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    TechnicianNotes = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Bookings__3214EC074E5289A3", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bookings_Request",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Bookings_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Conversations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    CustomerId = table.Column<int>(type: "int", nullable: false),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Conversa__3214EC07B007718E", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Conversations_Customer",
                        column: x => x.CustomerId,
                        principalTable: "CustomerProfiles",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Conversations_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Conversations_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    PaymentType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    PaymentMethod = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Pending"),
                    TransactionReference = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Provider = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    ProviderTransactionId = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    PaidAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Payments__3214EC07E975531E", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payments_Request",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    CustomerId = table.Column<int>(type: "int", nullable: false),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Reviews__3214EC07A804FF76", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_Customer",
                        column: x => x.CustomerId,
                        principalTable: "CustomerProfiles",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Reviews_Request",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Reviews_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ServiceRequestFiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    FileUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    FileType = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "Image"),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ServiceR__3214EC0714E20FA2", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ServiceRequestImages_Request",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ServiceRequestOffers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    TechnicianId = table.Column<int>(type: "int", nullable: false),
                    ProposedPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    TechnicianNote = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Pending"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RespondedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceRequestOffers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ServiceRequestOffers_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ServiceRequestOffers_Technician",
                        column: x => x.TechnicianId,
                        principalTable: "TechnicianProfiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ServiceRequestStatusHistory",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    OldStatus = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    NewStatus = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    ChangedByUserId = table.Column<int>(type: "int", nullable: false),
                    ChangedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ServiceR__3214EC071F6475A8", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StatusHistory_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_StatusHistory_User",
                        column: x => x.ChangedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SupportTickets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: true),
                    Subject = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Open"),
                    Priority = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "Medium"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SupportT__3214EC07D37A6F74", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SupportTickets_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SupportTickets_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserPromoCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    PromoCodeId = table.Column<int>(type: "int", nullable: false),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__UserProm__3214EC079CC9A3B0", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserPromoCodes_PromoCode",
                        column: x => x.PromoCodeId,
                        principalTable: "PromoCodes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserPromoCodes_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserPromoCodes_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "WalletTransactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WalletId = table.Column<int>(type: "int", nullable: false),
                    ServiceRequestId = table.Column<int>(type: "int", nullable: true),
                    Amount = table.Column<decimal>(type: "decimal(12,2)", nullable: false),
                    BalanceBefore = table.Column<decimal>(type: "decimal(12,2)", nullable: true),
                    BalanceAfter = table.Column<decimal>(type: "decimal(12,2)", nullable: true),
                    TransactionType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__WalletTr__3214EC078EB50875", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WalletTransactions_ServiceRequest",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_WalletTransactions_Wallet",
                        column: x => x.WalletId,
                        principalTable: "TechnicianWallets",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "VerificationCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    BookingId = table.Column<int>(type: "int", nullable: true),
                    CodeHash = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Purpose = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Channel = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Attempts = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VerificationCodes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_VerificationCodes_Booking",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_VerificationCodes_User",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Messages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ConversationId = table.Column<int>(type: "int", nullable: false),
                    SenderId = table.Column<int>(type: "int", nullable: false),
                    MessageText = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    AttachmentUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    AttachmentType = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    SentAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Messages__3214EC078A6F6236", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Messages_Conversation",
                        column: x => x.ConversationId,
                        principalTable: "Conversations",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Messages_Sender",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PaymentAttempts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentId = table.Column<int>(type: "int", nullable: false),
                    Provider = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ProviderTransactionId = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false, defaultValue: "Pending"),
                    FailureReason = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentAttempts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PaymentAttempts_Payment",
                        column: x => x.PaymentId,
                        principalTable: "Payments",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SupportMessages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SupportTicketId = table.Column<int>(type: "int", nullable: false),
                    SenderId = table.Column<int>(type: "int", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    AttachmentUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SupportM__3214EC0778607336", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SupportMessages_Sender",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SupportMessages_Ticket",
                        column: x => x.SupportTicketId,
                        principalTable: "SupportTickets",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Addresses_CityId_GovernorateId",
                table: "Addresses",
                columns: new[] { "CityId", "GovernorateId" });

            migrationBuilder.CreateIndex(
                name: "IX_Addresses_CustomerId",
                table: "Addresses",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_Addresses_GovernorateId",
                table: "Addresses",
                column: "GovernorateId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_TechnicianId",
                table: "Bookings",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "UQ__Bookings__790F6C8A34F866A4",
                table: "Bookings",
                column: "ServiceRequestId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ_Cities_Governorate_Name",
                table: "Cities",
                columns: new[] { "GovernorateId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ_Cities_Id_Governorate",
                table: "Cities",
                columns: new[] { "Id", "GovernorateId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Conversations_CustomerId",
                table: "Conversations",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_Conversations_TechnicianId",
                table: "Conversations",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "UQ__Conversa__790F6C8A898F216E",
                table: "Conversations",
                column: "ServiceRequestId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Customer__1788CC4D4EA9CC72",
                table: "CustomerProfiles",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EmailVerificationTokens_UserId",
                table: "EmailVerificationTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UQ__EmailVer__1EB4F817C701AAD0",
                table: "EmailVerificationTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ExternalLogins_UserId",
                table: "ExternalLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UX_ExternalLogins_Provider_Subject",
                table: "ExternalLogins",
                columns: new[] { "Provider", "ProviderSubjectId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Governor__737584F6D9D82374",
                table: "Governorates",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Messages_ConversationId",
                table: "Messages",
                column: "ConversationId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_SenderId",
                table: "Messages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserId",
                table: "Notifications",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PasswordResetTokens_UserId",
                table: "PasswordResetTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UQ__Password__1EB4F81771672048",
                table: "PasswordResetTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PaymentAttempts_PaymentId",
                table: "PaymentAttempts",
                column: "PaymentId");

            migrationBuilder.CreateIndex(
                name: "UX_PaymentAttempts_ProviderTransactionId",
                table: "PaymentAttempts",
                column: "ProviderTransactionId",
                unique: true,
                filter: "[ProviderTransactionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_ServiceRequestId",
                table: "Payments",
                column: "ServiceRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_Payouts_TechnicianId",
                table: "Payouts",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "UQ__PromoCod__A25C5AA7AEEF8AB8",
                table: "PromoCodes",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserId",
                table: "RefreshTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UQ__RefreshT__1EB4F817A73115DC",
                table: "RefreshTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UX_RefreshTokens_TokenHash",
                table: "RefreshTokens",
                column: "TokenHash",
                unique: true,
                filter: "[TokenHash] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_CustomerId",
                table: "Reviews",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_TechnicianId",
                table: "Reviews",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "UQ__Reviews__790F6C8A5AF653A1",
                table: "Reviews",
                column: "ServiceRequestId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ServicePricing_CityId",
                table: "ServicePricing",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "UX_ServicePricing_Active_Service_City",
                table: "ServicePricing",
                columns: new[] { "ServiceId", "CityId" },
                unique: true,
                filter: "[IsActive] = 1 AND [CityId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "UX_ServicePricing_Active_Service_Global",
                table: "ServicePricing",
                column: "ServiceId",
                unique: true,
                filter: "[IsActive] = 1 AND [CityId] IS NULL");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequestFiles_ServiceRequestId",
                table: "ServiceRequestFiles",
                column: "ServiceRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequestOffers_ServiceRequestId_Status",
                table: "ServiceRequestOffers",
                columns: new[] { "ServiceRequestId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequestOffers_TechnicianId_Status",
                table: "ServiceRequestOffers",
                columns: new[] { "TechnicianId", "Status" });

            migrationBuilder.CreateIndex(
                name: "UX_ServiceRequestOffers_OneAccepted",
                table: "ServiceRequestOffers",
                column: "ServiceRequestId",
                unique: true,
                filter: "[Status] = 'Accepted'");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_AddressId",
                table: "ServiceRequests",
                column: "AddressId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_CustomerId",
                table: "ServiceRequests",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_ServiceId",
                table: "ServiceRequests",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequestStatusHistory_ChangedByUserId",
                table: "ServiceRequestStatusHistory",
                column: "ChangedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequestStatusHistory_ServiceRequestId",
                table: "ServiceRequestStatusHistory",
                column: "ServiceRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_SupportMessages_SenderId",
                table: "SupportMessages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_SupportMessages_SupportTicketId",
                table: "SupportMessages",
                column: "SupportTicketId");

            migrationBuilder.CreateIndex(
                name: "IX_SupportTickets_ServiceRequestId",
                table: "SupportTickets",
                column: "ServiceRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_SupportTickets_UserId",
                table: "SupportTickets",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianAvailability_TechnicianId",
                table: "TechnicianAvailability",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianDocuments_TechnicianId",
                table: "TechnicianDocuments",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "UQ__Technici__1788CC4DC4C75A2C",
                table: "TechnicianProfiles",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianServiceAreas_CityId",
                table: "TechnicianServiceAreas",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianServices_ServiceId",
                table: "TechnicianServices",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "UQ__Technici__301F812009726F2F",
                table: "TechnicianWallets",
                column: "TechnicianId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserDevices_UserId_IsActive",
                table: "UserDevices",
                columns: new[] { "UserId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "UX_UserDevices_DeviceToken",
                table: "UserDevices",
                column: "DeviceToken",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserPromoCodes_PromoCodeId",
                table: "UserPromoCodes",
                column: "PromoCodeId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPromoCodes_UserId",
                table: "UserPromoCodes",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UQ_UserPromoCodes_Request",
                table: "UserPromoCodes",
                column: "ServiceRequestId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Users__85FB4E38F617F54B",
                table: "Users",
                column: "PhoneNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Users__A9D10534097A4A1C",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_VerificationCodes_BookingId_Purpose_UsedAt",
                table: "VerificationCodes",
                columns: new[] { "BookingId", "Purpose", "UsedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_VerificationCodes_UserId_Purpose_Channel_CreatedAt",
                table: "VerificationCodes",
                columns: new[] { "UserId", "Purpose", "Channel", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_WalletTransactions_ServiceRequestId",
                table: "WalletTransactions",
                column: "ServiceRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletTransactions_WalletId",
                table: "WalletTransactions",
                column: "WalletId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EmailVerificationTokens");

            migrationBuilder.DropTable(
                name: "ExternalLogins");

            migrationBuilder.DropTable(
                name: "Messages");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "PasswordResetTokens");

            migrationBuilder.DropTable(
                name: "PaymentAttempts");

            migrationBuilder.DropTable(
                name: "Payouts");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "ServicePricing");

            migrationBuilder.DropTable(
                name: "ServiceRequestFiles");

            migrationBuilder.DropTable(
                name: "ServiceRequestOffers");

            migrationBuilder.DropTable(
                name: "ServiceRequestStatusHistory");

            migrationBuilder.DropTable(
                name: "SupportMessages");

            migrationBuilder.DropTable(
                name: "TechnicianAvailability");

            migrationBuilder.DropTable(
                name: "TechnicianDocuments");

            migrationBuilder.DropTable(
                name: "TechnicianServiceAreas");

            migrationBuilder.DropTable(
                name: "TechnicianServices");

            migrationBuilder.DropTable(
                name: "UserDevices");

            migrationBuilder.DropTable(
                name: "UserPromoCodes");

            migrationBuilder.DropTable(
                name: "VerificationCodes");

            migrationBuilder.DropTable(
                name: "WalletTransactions");

            migrationBuilder.DropTable(
                name: "Conversations");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "SupportTickets");

            migrationBuilder.DropTable(
                name: "PromoCodes");

            migrationBuilder.DropTable(
                name: "Bookings");

            migrationBuilder.DropTable(
                name: "TechnicianWallets");

            migrationBuilder.DropTable(
                name: "ServiceRequests");

            migrationBuilder.DropTable(
                name: "TechnicianProfiles");

            migrationBuilder.DropTable(
                name: "Addresses");

            migrationBuilder.DropTable(
                name: "Services");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "CustomerProfiles");

            migrationBuilder.DropTable(
                name: "Governorates");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
