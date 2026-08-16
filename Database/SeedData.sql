USE HomeFixDb;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

/*
 Development-only seed data.
 Passwords:
   Admin@12345
   Customer@12345
   Tech@12345
   Support@12345
*/

/* =========================
   USERS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.admin@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Admin', 'seed.admin@homefix.local', '01000000001', 'Egg2MPvcl71dvxqnC3uP+Q==.L8NQ5MIo5/XQw48PygQbQMBCaTrrpC4KlU6hpgfUqGM=', 'Admin', 1, 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.customer1@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Customer One', 'seed.customer1@homefix.local', '01000000002', 'PYjOmsbmR0688ZV4VaZ0NQ==.B+yijS8G3i5yLtFuMGd9P3DlXdoxHGquLY2ulwqVzY8=', 'Customer', 1, 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.customer2@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Customer Two', 'seed.customer2@homefix.local', '01000000003', 'PYjOmsbmR0688ZV4VaZ0NQ==.B+yijS8G3i5yLtFuMGd9P3DlXdoxHGquLY2ulwqVzY8=', 'Customer', 1, 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.tech1@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Technician One', 'seed.tech1@homefix.local', '01000000004', '6TbqTywuderbNyygUmAo7w==.udwHGLVeWO6StR2MpO+xMXBaTfmjt//PoY9gSh6GbeY=', 'Technician', 1, 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.tech2@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Technician Two', 'seed.tech2@homefix.local', '01000000005', '6TbqTywuderbNyygUmAo7w==.udwHGLVeWO6StR2MpO+xMXBaTfmjt//PoY9gSh6GbeY=', 'Technician', 1, 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = 'seed.support@homefix.local')
    INSERT dbo.Users (FullName, Email, PhoneNumber, PasswordHash, Role, IsActive, IsEmailVerified, IsPhoneVerified)
    VALUES ('Seed Support', 'seed.support@homefix.local', '01000000006', 'x/NjdJ+HsUMbuztnfvvRQA==.3fXU6nkD9icmPJPpC6tDK/qn7mFIXgtkKZ4NVIzrK7E=', 'Admin', 1, 1, 1);

DECLARE @AdminId int, @Customer1UserId int, @Customer2UserId int, @Tech1UserId int, @Tech2UserId int, @SupportId int;
SELECT @AdminId = Id FROM dbo.Users WHERE Email = 'seed.admin@homefix.local';
SELECT @Customer1UserId = Id FROM dbo.Users WHERE Email = 'seed.customer1@homefix.local';
SELECT @Customer2UserId = Id FROM dbo.Users WHERE Email = 'seed.customer2@homefix.local';
SELECT @Tech1UserId = Id FROM dbo.Users WHERE Email = 'seed.tech1@homefix.local';
SELECT @Tech2UserId = Id FROM dbo.Users WHERE Email = 'seed.tech2@homefix.local';
SELECT @SupportId = Id FROM dbo.Users WHERE Email = 'seed.support@homefix.local';

/* =========================
   GOVERNORATES / CITIES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Governorates WHERE Name = N'Cairo')
    INSERT dbo.Governorates (Name, IsActive) VALUES (N'Cairo', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Governorates WHERE Name = N'Giza')
    INSERT dbo.Governorates (Name, IsActive) VALUES (N'Giza', 1);

DECLARE @CairoGovId int, @GizaGovId int;
SELECT @CairoGovId = Id FROM dbo.Governorates WHERE Name = N'Cairo';
SELECT @GizaGovId = Id FROM dbo.Governorates WHERE Name = N'Giza';

IF NOT EXISTS (SELECT 1 FROM dbo.Cities WHERE Name = N'Nasr City' AND GovernorateId = @CairoGovId)
    INSERT dbo.Cities (GovernorateId, Name, IsActive) VALUES (@CairoGovId, N'Nasr City', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Cities WHERE Name = N'Heliopolis' AND GovernorateId = @CairoGovId)
    INSERT dbo.Cities (GovernorateId, Name, IsActive) VALUES (@CairoGovId, N'Heliopolis', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Cities WHERE Name = N'6th of October' AND GovernorateId = @GizaGovId)
    INSERT dbo.Cities (GovernorateId, Name, IsActive) VALUES (@GizaGovId, N'6th of October', 1);

DECLARE @NasrCityId int, @HeliopolisId int, @OctoberId int;
SELECT @NasrCityId = Id FROM dbo.Cities WHERE Name = N'Nasr City' AND GovernorateId = @CairoGovId;
SELECT @HeliopolisId = Id FROM dbo.Cities WHERE Name = N'Heliopolis' AND GovernorateId = @CairoGovId;
SELECT @OctoberId = Id FROM dbo.Cities WHERE Name = N'6th of October' AND GovernorateId = @GizaGovId;

/* =========================
   CUSTOMER / TECHNICIAN PROFILES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.CustomerProfiles WHERE UserId = @Customer1UserId)
    INSERT dbo.CustomerProfiles (UserId, ProfileImageUrl) VALUES (@Customer1UserId, 'https://example.com/customer1.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.CustomerProfiles WHERE UserId = @Customer2UserId)
    INSERT dbo.CustomerProfiles (UserId, ProfileImageUrl) VALUES (@Customer2UserId, 'https://example.com/customer2.jpg');

DECLARE @Customer1Id int, @Customer2Id int;
SELECT @Customer1Id = Id FROM dbo.CustomerProfiles WHERE UserId = @Customer1UserId;
SELECT @Customer2Id = Id FROM dbo.CustomerProfiles WHERE UserId = @Customer2UserId;

IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianProfiles WHERE UserId = @Tech1UserId)
    INSERT dbo.TechnicianProfiles (UserId, Bio, ProfileImageUrl, YearsOfExperience, IsVerified, IsAvailable, AverageRating, TotalJobs, CurrentLatitude, CurrentLongitude)
    VALUES (@Tech1UserId, N'Experienced electrician and home maintenance technician.', 'https://example.com/tech1.jpg', 7, 1, 1, 4.80, 32, 30.0444, 31.2357);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianProfiles WHERE UserId = @Tech2UserId)
    INSERT dbo.TechnicianProfiles (UserId, Bio, ProfileImageUrl, YearsOfExperience, IsVerified, IsAvailable, AverageRating, TotalJobs, CurrentLatitude, CurrentLongitude)
    VALUES (@Tech2UserId, N'Plumbing and general home repair specialist.', 'https://example.com/tech2.jpg', 5, 1, 1, 4.60, 21, 30.0626, 31.2497);

DECLARE @Tech1Id int, @Tech2Id int;
SELECT @Tech1Id = Id FROM dbo.TechnicianProfiles WHERE UserId = @Tech1UserId;
SELECT @Tech2Id = Id FROM dbo.TechnicianProfiles WHERE UserId = @Tech2UserId;

/* =========================
   SERVICES / PRICING
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Services WHERE Name = N'Electrical Repair')
    INSERT dbo.Services (Name, Description, ImageUrl, EstimatedDurationMinutes, IsActive)
    VALUES (N'Electrical Repair', N'Home electrical inspection and repair.', 'https://example.com/electrical.jpg', 90, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Services WHERE Name = N'Plumbing Repair')
    INSERT dbo.Services (Name, Description, ImageUrl, EstimatedDurationMinutes, IsActive)
    VALUES (N'Plumbing Repair', N'Leaks, faucets, pipes and general plumbing.', 'https://example.com/plumbing.jpg', 90, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Services WHERE Name = N'Air Conditioner Maintenance')
    INSERT dbo.Services (Name, Description, ImageUrl, EstimatedDurationMinutes, IsActive)
    VALUES (N'Air Conditioner Maintenance', N'AC inspection, cleaning and maintenance.', 'https://example.com/ac.jpg', 120, 1);

DECLARE @ElectricalId int, @PlumbingId int, @AcId int;
SELECT @ElectricalId = Id FROM dbo.Services WHERE Name = N'Electrical Repair';
SELECT @PlumbingId = Id FROM dbo.Services WHERE Name = N'Plumbing Repair';
SELECT @AcId = Id FROM dbo.Services WHERE Name = N'Air Conditioner Maintenance';

IF NOT EXISTS (SELECT 1 FROM dbo.ServicePricing WHERE ServiceId = @ElectricalId AND CityId = @NasrCityId)
    INSERT dbo.ServicePricing (ServiceId, CityId, VisitFee, MinimumPrice, MaximumPrice, IsActive) VALUES (@ElectricalId, @NasrCityId, 100, 250, 800, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.ServicePricing WHERE ServiceId = @PlumbingId AND CityId = @NasrCityId)
    INSERT dbo.ServicePricing (ServiceId, CityId, VisitFee, MinimumPrice, MaximumPrice, IsActive) VALUES (@PlumbingId, @NasrCityId, 80, 200, 700, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.ServicePricing WHERE ServiceId = @AcId AND CityId = @HeliopolisId)
    INSERT dbo.ServicePricing (ServiceId, CityId, VisitFee, MinimumPrice, MaximumPrice, IsActive) VALUES (@AcId, @HeliopolisId, 120, 300, 900, 1);

/* =========================
   ADDRESSES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Addresses WHERE CustomerId = @Customer1Id AND FullAddress = N'12 Abbas El Akkad St, Nasr City')
    INSERT dbo.Addresses (CustomerId, Label, FullAddress, Latitude, Longitude, BuildingNumber, FloorNumber, ApartmentNumber, AdditionalInstructions, IsDefault, GovernorateId, CityId)
    VALUES (@Customer1Id, N'Home', N'12 Abbas El Akkad St, Nasr City', 30.0511, 31.3656, N'12', N'3', N'7', N'Call before arrival.', 1, @CairoGovId, @NasrCityId);
IF NOT EXISTS (SELECT 1 FROM dbo.Addresses WHERE CustomerId = @Customer2Id AND FullAddress = N'8 Merghany St, Heliopolis')
    INSERT dbo.Addresses (CustomerId, Label, FullAddress, Latitude, Longitude, BuildingNumber, FloorNumber, ApartmentNumber, AdditionalInstructions, IsDefault, GovernorateId, CityId)
    VALUES (@Customer2Id, N'Home', N'8 Merghany St, Heliopolis', 30.0875, 31.3280, N'8', N'2', N'4', N'Entrance is next to the pharmacy.', 1, @CairoGovId, @HeliopolisId);

DECLARE @Address1Id int, @Address2Id int;
SELECT @Address1Id = Id FROM dbo.Addresses WHERE CustomerId = @Customer1Id AND FullAddress = N'12 Abbas El Akkad St, Nasr City';
SELECT @Address2Id = Id FROM dbo.Addresses WHERE CustomerId = @Customer2Id AND FullAddress = N'8 Merghany St, Heliopolis';

/* =========================
   TECHNICIAN AREAS / SERVICES / AVAILABILITY
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServices WHERE TechnicianId = @Tech1Id AND ServiceId = @ElectricalId)
    INSERT dbo.TechnicianServices (TechnicianId, ServiceId) VALUES (@Tech1Id, @ElectricalId);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServices WHERE TechnicianId = @Tech1Id AND ServiceId = @AcId)
    INSERT dbo.TechnicianServices (TechnicianId, ServiceId) VALUES (@Tech1Id, @AcId);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServices WHERE TechnicianId = @Tech2Id AND ServiceId = @PlumbingId)
    INSERT dbo.TechnicianServices (TechnicianId, ServiceId) VALUES (@Tech2Id, @PlumbingId);

IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServiceAreas WHERE TechnicianId = @Tech1Id AND CityId = @NasrCityId)
    INSERT dbo.TechnicianServiceAreas (TechnicianId, CityId) VALUES (@Tech1Id, @NasrCityId);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServiceAreas WHERE TechnicianId = @Tech1Id AND CityId = @HeliopolisId)
    INSERT dbo.TechnicianServiceAreas (TechnicianId, CityId) VALUES (@Tech1Id, @HeliopolisId);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianServiceAreas WHERE TechnicianId = @Tech2Id AND CityId = @NasrCityId)
    INSERT dbo.TechnicianServiceAreas (TechnicianId, CityId) VALUES (@Tech2Id, @NasrCityId);

IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianAvailability WHERE TechnicianId = @Tech1Id AND DayOfWeek = 1 AND StartTime = '09:00' AND EndTime = '17:00')
    INSERT dbo.TechnicianAvailability (TechnicianId, DayOfWeek, StartTime, EndTime, IsAvailable) VALUES (@Tech1Id, 1, '09:00', '17:00', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianAvailability WHERE TechnicianId = @Tech1Id AND DayOfWeek = 3 AND StartTime = '09:00' AND EndTime = '17:00')
    INSERT dbo.TechnicianAvailability (TechnicianId, DayOfWeek, StartTime, EndTime, IsAvailable) VALUES (@Tech1Id, 3, '09:00', '17:00', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianAvailability WHERE TechnicianId = @Tech2Id AND DayOfWeek = 2 AND StartTime = '10:00' AND EndTime = '18:00')
    INSERT dbo.TechnicianAvailability (TechnicianId, DayOfWeek, StartTime, EndTime, IsAvailable) VALUES (@Tech2Id, 2, '10:00', '18:00', 1);

/* =========================
   WALLETS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianWallets WHERE TechnicianId = @Tech1Id)
    INSERT dbo.TechnicianWallets (TechnicianId, Balance) VALUES (@Tech1Id, 1500);
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianWallets WHERE TechnicianId = @Tech2Id)
    INSERT dbo.TechnicianWallets (TechnicianId, Balance) VALUES (@Tech2Id, 900);

DECLARE @Wallet1Id int, @Wallet2Id int;
SELECT @Wallet1Id = Id FROM dbo.TechnicianWallets WHERE TechnicianId = @Tech1Id;
SELECT @Wallet2Id = Id FROM dbo.TechnicianWallets WHERE TechnicianId = @Tech2Id;

/* =========================
   SERVICE REQUESTS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequests WHERE CustomerId = @Customer1Id AND Description = N'Kitchen lights are flickering and one socket stopped working.')
    INSERT dbo.ServiceRequests (CustomerId, ServiceId, AddressId, Description, PreferredDate, PreferredTime, Status, VisitFee, UpdatedAt)
    VALUES (@Customer1Id, @ElectricalId, @Address1Id, N'Kitchen lights are flickering and one socket stopped working.', CAST(GETDATE()+1 AS date), '14:00', N'Pending', 100, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequests WHERE CustomerId = @Customer1Id AND Description = N'AC needs cleaning before summer.')
    INSERT dbo.ServiceRequests (CustomerId, ServiceId, AddressId, Description, PreferredDate, PreferredTime, Status, VisitFee, UpdatedAt)
    VALUES (@Customer1Id, @AcId, @Address1Id, N'AC needs cleaning before summer.', CAST(GETDATE()+2 AS date), '11:00', N'Confirmed', 120, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequests WHERE CustomerId = @Customer2Id AND Description = N'Bathroom faucet is leaking.')
    INSERT dbo.ServiceRequests (CustomerId, ServiceId, AddressId, Description, PreferredDate, PreferredTime, Status, VisitFee, UpdatedAt)
    VALUES (@Customer2Id, @PlumbingId, @Address2Id, N'Bathroom faucet is leaking.', CAST(GETDATE()+1 AS date), '16:00', N'Completed', 80, GETDATE());

DECLARE @Request1Id int, @Request2Id int, @Request3Id int;
SELECT @Request1Id = Id FROM dbo.ServiceRequests WHERE CustomerId = @Customer1Id AND Description = N'Kitchen lights are flickering and one socket stopped working.';
SELECT @Request2Id = Id FROM dbo.ServiceRequests WHERE CustomerId = @Customer1Id AND Description = N'AC needs cleaning before summer.';
SELECT @Request3Id = Id FROM dbo.ServiceRequests WHERE CustomerId = @Customer2Id AND Description = N'Bathroom faucet is leaking.';

/* =========================
   OFFERS / BOOKING
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestOffers WHERE ServiceRequestId = @Request1Id AND TechnicianId = @Tech1Id)
    INSERT dbo.ServiceRequestOffers (ServiceRequestId, TechnicianId, ProposedPrice, TechnicianNote, Status, ExpiresAt)
    VALUES (@Request1Id, @Tech1Id, 450, N'I can inspect the wiring and replace the faulty socket if needed.', N'Pending', DATEADD(day, 2, GETDATE()));

IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestOffers WHERE ServiceRequestId = @Request2Id AND TechnicianId = @Tech1Id)
    INSERT dbo.ServiceRequestOffers (ServiceRequestId, TechnicianId, ProposedPrice, TechnicianNote, Status, RespondedAt)
    VALUES (@Request2Id, @Tech1Id, 550, N'Full AC cleaning and inspection.', N'Accepted', GETDATE());

IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestOffers WHERE ServiceRequestId = @Request3Id AND TechnicianId = @Tech2Id)
    INSERT dbo.ServiceRequestOffers (ServiceRequestId, TechnicianId, ProposedPrice, TechnicianNote, Status, RespondedAt)
    VALUES (@Request3Id, @Tech2Id, 320, N'Faucet replacement and leak inspection.', N'Accepted', GETDATE());

IF NOT EXISTS (SELECT 1 FROM dbo.Bookings WHERE ServiceRequestId = @Request2Id AND TechnicianId = @Tech1Id)
    INSERT dbo.Bookings (ServiceRequestId, TechnicianId, Status, AgreedPrice, AcceptedAt, ArrivedAt, StartedAt)
    VALUES (@Request2Id, @Tech1Id, N'InProgress', 550, GETDATE(), GETDATE(), GETDATE());
IF NOT EXISTS (SELECT 1 FROM dbo.Bookings WHERE ServiceRequestId = @Request3Id AND TechnicianId = @Tech2Id)
    INSERT dbo.Bookings (ServiceRequestId, TechnicianId, Status, AgreedPrice, AcceptedAt, ArrivedAt, StartedAt, CompletedAt, FinalPrice, TechnicianNotes)
    VALUES (@Request3Id, @Tech2Id, N'Completed', 320, DATEADD(hour,-4,GETDATE()), DATEADD(hour,-3,GETDATE()), DATEADD(hour,-3,GETDATE()), DATEADD(hour,-2,GETDATE()), 320, N'Faucet replaced successfully.');

DECLARE @Booking2Id int, @Booking3Id int;
SELECT @Booking2Id = Id FROM dbo.Bookings WHERE ServiceRequestId = @Request2Id AND TechnicianId = @Tech1Id;
SELECT @Booking3Id = Id FROM dbo.Bookings WHERE ServiceRequestId = @Request3Id AND TechnicianId = @Tech2Id;

/* =========================
   PAYMENTS / ATTEMPTS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Payments WHERE ServiceRequestId = @Request2Id AND PaymentType = N'Service')
    INSERT dbo.Payments (ServiceRequestId, Amount, PaymentType, PaymentMethod, Status, TransactionReference, Provider)
    VALUES (@Request2Id, 550, N'Service', N'Card', N'Paid', N'SEED-PAY-1002', N'SeedProvider');
IF NOT EXISTS (SELECT 1 FROM dbo.Payments WHERE ServiceRequestId = @Request3Id AND PaymentType = N'Service')
    INSERT dbo.Payments (ServiceRequestId, Amount, PaymentType, PaymentMethod, Status, TransactionReference, Provider, PaidAt)
    VALUES (@Request3Id, 320, N'Service', N'Cash', N'Paid', N'SEED-PAY-1003', N'SeedProvider', DATEADD(hour,-2,GETDATE()));

DECLARE @Payment2Id int, @Payment3Id int;
SELECT @Payment2Id = Id FROM dbo.Payments WHERE ServiceRequestId = @Request2Id AND PaymentType = N'Service';
SELECT @Payment3Id = Id FROM dbo.Payments WHERE ServiceRequestId = @Request3Id AND PaymentType = N'Service';

IF NOT EXISTS (SELECT 1 FROM dbo.PaymentAttempts WHERE PaymentId = @Payment2Id AND ProviderTransactionId = N'SEED-TX-1002')
    INSERT dbo.PaymentAttempts (PaymentId, Provider, ProviderTransactionId, Amount, Status, CompletedAt)
    VALUES (@Payment2Id, N'SeedProvider', N'SEED-TX-1002', 550, N'Succeeded', GETDATE());
IF NOT EXISTS (SELECT 1 FROM dbo.PaymentAttempts WHERE PaymentId = @Payment3Id AND ProviderTransactionId = N'SEED-TX-1003')
    INSERT dbo.PaymentAttempts (PaymentId, Provider, ProviderTransactionId, Amount, Status, CompletedAt)
    VALUES (@Payment3Id, N'SeedProvider', N'SEED-TX-1003', 320, N'Succeeded', DATEADD(hour,-2,GETDATE()));

/* =========================
   PAYOUTS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Payouts WHERE TechnicianId = @Tech1Id AND TransactionReference = N'SEED-PAYOUT-1001')
    INSERT dbo.Payouts (TechnicianId, Amount, Status, PaymentMethod, TransactionReference, CompletedAt)
    VALUES (@Tech1Id, 400, N'Pending', N'BankTransfer', N'SEED-PAYOUT-1001', NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.Payouts WHERE TechnicianId = @Tech2Id AND TransactionReference = N'SEED-PAYOUT-1002')
    INSERT dbo.Payouts (TechnicianId, Amount, Status, PaymentMethod, TransactionReference, CompletedAt)
    VALUES (@Tech2Id, 250, N'Completed', N'BankTransfer', N'SEED-PAYOUT-1002', DATEADD(day,-1,GETDATE()));

/* =========================
   WALLET TRANSACTIONS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.WalletTransactions WHERE WalletId = @Wallet1Id AND Description = N'Seed completed service earnings')
    INSERT dbo.WalletTransactions (WalletId, ServiceRequestId, Amount, BalanceBefore, BalanceAfter, TransactionType, Description)
    VALUES (@Wallet1Id, @Request2Id, 550, 950, 1500, N'Earning', N'Seed completed service earnings');
IF NOT EXISTS (SELECT 1 FROM dbo.WalletTransactions WHERE WalletId = @Wallet2Id AND Description = N'Seed completed plumbing earnings')
    INSERT dbo.WalletTransactions (WalletId, ServiceRequestId, Amount, BalanceBefore, BalanceAfter, TransactionType, Description)
    VALUES (@Wallet2Id, @Request3Id, 320, 580, 900, N'Earning', N'Seed completed plumbing earnings');

/* =========================
   REVIEWS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Reviews WHERE ServiceRequestId = @Request3Id AND CustomerId = @Customer2Id AND TechnicianId = @Tech2Id)
    INSERT dbo.Reviews (ServiceRequestId, CustomerId, TechnicianId, Rating, Comment)
    VALUES (@Request3Id, @Customer2Id, @Tech2Id, 5, N'Fast and professional service.');

/* =========================
   PROMO CODES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.PromoCodes WHERE Code = N'SEED10')
    INSERT dbo.PromoCodes (Code, DiscountType, DiscountValue, MaxUses, UsedCount, StartDate, EndDate, IsActive)
    VALUES (N'SEED10', N'Percentage', 10, 100, 0, DATEADD(day,-10,GETDATE()), DATEADD(day,30,GETDATE()), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.PromoCodes WHERE Code = N'SEED50')
    INSERT dbo.PromoCodes (Code, DiscountType, DiscountValue, MaxUses, UsedCount, StartDate, EndDate, IsActive)
    VALUES (N'SEED50', N'Fixed', 50, 50, 0, DATEADD(day,-10,GETDATE()), DATEADD(day,30,GETDATE()), 1);

DECLARE @Promo10Id int;
SELECT @Promo10Id = Id FROM dbo.PromoCodes WHERE Code = N'SEED10';

IF NOT EXISTS (SELECT 1 FROM dbo.UserPromoCodes WHERE UserId = @Customer1UserId AND PromoCodeId = @Promo10Id AND ServiceRequestId = @Request2Id)
    INSERT dbo.UserPromoCodes (UserId, PromoCodeId, ServiceRequestId, DiscountAmount)
    VALUES (@Customer1UserId, @Promo10Id, @Request2Id, 55);

/* =========================
   CONVERSATIONS / MESSAGES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Conversations WHERE ServiceRequestId = @Request2Id AND CustomerId = @Customer1Id AND TechnicianId = @Tech1Id)
    INSERT dbo.Conversations (ServiceRequestId, CustomerId, TechnicianId)
    VALUES (@Request2Id, @Customer1Id, @Tech1Id);

DECLARE @ConversationId int;
SELECT @ConversationId = Id FROM dbo.Conversations WHERE ServiceRequestId = @Request2Id AND CustomerId = @Customer1Id AND TechnicianId = @Tech1Id;

IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @ConversationId AND MessageText = N'Hello, I will arrive at the scheduled time.')
    INSERT dbo.Messages (ConversationId, SenderId, MessageText, IsRead)
    VALUES (@ConversationId, @Tech1UserId, N'Hello, I will arrive at the scheduled time.', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE ConversationId = @ConversationId AND MessageText = N'Great, thank you.')
    INSERT dbo.Messages (ConversationId, SenderId, MessageText, IsRead)
    VALUES (@ConversationId, @Customer1UserId, N'Great, thank you.', 0);

/* =========================
   SUPPORT
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.SupportTickets WHERE UserId = @Customer1UserId AND Subject = N'Seed support ticket')
    INSERT dbo.SupportTickets (UserId, ServiceRequestId, Subject, Description, Status, Priority)
    VALUES (@Customer1UserId, @Request2Id, N'Seed support ticket', N'Test ticket for support workflow.', N'Open', N'Medium');

DECLARE @TicketId int;
SELECT @TicketId = Id FROM dbo.SupportTickets WHERE UserId = @Customer1UserId AND Subject = N'Seed support ticket';

IF NOT EXISTS (SELECT 1 FROM dbo.SupportMessages WHERE SupportTicketId = @TicketId AND Message = N'Customer opened a test support ticket.')
    INSERT dbo.SupportMessages (SupportTicketId, SenderId, Message)
    VALUES (@TicketId, @Customer1UserId, N'Customer opened a test support ticket.');
IF NOT EXISTS (SELECT 1 FROM dbo.SupportMessages WHERE SupportTicketId = @TicketId AND Message = N'Support has received your request.')
    INSERT dbo.SupportMessages (SupportTicketId, SenderId, Message)
    VALUES (@TicketId, @SupportId, N'Support has received your request.');

/* =========================
   NOTIFICATIONS / DEVICES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Notifications WHERE UserId = @Customer1UserId AND Title = N'Seed notification')
    INSERT dbo.Notifications (UserId, Title, Message, IsRead, Type, ReferenceId)
    VALUES (@Customer1UserId, N'Seed notification', N'Your service request has a new offer.', 0, N'ServiceRequestOffer', @Request1Id);
IF NOT EXISTS (SELECT 1 FROM dbo.Notifications WHERE UserId = @Tech1UserId AND Title = N'Seed technician notification')
    INSERT dbo.Notifications (UserId, Title, Message, IsRead, Type, ReferenceId)
    VALUES (@Tech1UserId, N'Seed technician notification', N'A customer has requested a service.', 0, N'ServiceRequest', @Request1Id);

IF NOT EXISTS (SELECT 1 FROM dbo.UserDevices WHERE UserId = @Customer1UserId AND DeviceToken = N'SEED-DEVICE-CUSTOMER-1')
    INSERT dbo.UserDevices (UserId, DeviceToken, Platform, IsActive, LastSeenAt)
    VALUES (@Customer1UserId, N'SEED-DEVICE-CUSTOMER-1', N'Android', 1, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dbo.UserDevices WHERE UserId = @Tech1UserId AND DeviceToken = N'SEED-DEVICE-TECH-1')
    INSERT dbo.UserDevices (UserId, DeviceToken, Platform, IsActive, LastSeenAt)
    VALUES (@Tech1UserId, N'SEED-DEVICE-TECH-1', N'Android', 1, GETDATE());

/* =========================
   FILES / STATUS HISTORY
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestFiles WHERE ServiceRequestId = @Request1Id AND FileUrl = N'https://example.com/seed/request1.jpg')
    INSERT dbo.ServiceRequestFiles (ServiceRequestId, FileUrl, FileType)
    VALUES (@Request1Id, N'https://example.com/seed/request1.jpg', N'Image');

IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestStatusHistory WHERE ServiceRequestId = @Request2Id AND NewStatus = N'Confirmed' AND ChangedByUserId = @Tech1UserId)
    INSERT dbo.ServiceRequestStatusHistory (ServiceRequestId, OldStatus, NewStatus, ChangedByUserId)
    VALUES (@Request2Id, N'Pending', N'Confirmed', @Tech1UserId);

IF NOT EXISTS (SELECT 1 FROM dbo.ServiceRequestStatusHistory WHERE ServiceRequestId = @Request3Id AND NewStatus = N'Completed' AND ChangedByUserId = @Tech2UserId)
    INSERT dbo.ServiceRequestStatusHistory (ServiceRequestId, OldStatus, NewStatus, ChangedByUserId)
    VALUES (@Request3Id, N'InProgress', N'Completed', @Tech2UserId);

/* =========================
   TECHNICIAN DOCUMENTS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianDocuments WHERE TechnicianId = @Tech1Id AND DocumentType = N'NationalId')
    INSERT dbo.TechnicianDocuments (TechnicianId, DocumentType, DocumentUrl, Status)
    VALUES (@Tech1Id, N'NationalId', N'https://example.com/seed/tech1-id.pdf', N'Approved');
IF NOT EXISTS (SELECT 1 FROM dbo.TechnicianDocuments WHERE TechnicianId = @Tech2Id AND DocumentType = N'NationalId')
    INSERT dbo.TechnicianDocuments (TechnicianId, DocumentType, DocumentUrl, Status)
    VALUES (@Tech2Id, N'NationalId', N'https://example.com/seed/tech2-id.pdf', N'Pending');

/* =========================
   AUTH / VERIFICATION SUPPORT TABLES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.ExternalLogins WHERE UserId = @Customer1UserId AND Provider = N'Google' AND ProviderSubjectId = N'SEED-GOOGLE-CUSTOMER-1')
    INSERT dbo.ExternalLogins (UserId, Provider, ProviderSubjectId, Email)
    VALUES (@Customer1UserId, N'Google', N'SEED-GOOGLE-CUSTOMER-1', N'seed.customer1@homefix.local');

IF NOT EXISTS (SELECT 1 FROM dbo.EmailVerificationTokens WHERE UserId = @Customer2UserId AND Token = N'SEED-EMAIL-TOKEN-1')
    INSERT dbo.EmailVerificationTokens (UserId, Token, ExpiresAt)
    VALUES (@Customer2UserId, N'SEED-EMAIL-TOKEN-1', DATEADD(day, 1, GETDATE()));

IF NOT EXISTS (SELECT 1 FROM dbo.PasswordResetTokens WHERE UserId = @Customer2UserId AND Token = N'SEED-PASSWORD-TOKEN-1')
    INSERT dbo.PasswordResetTokens (UserId, Token, ExpiresAt)
    VALUES (@Customer2UserId, N'SEED-PASSWORD-TOKEN-1', DATEADD(hour, 1, GETDATE()));

IF NOT EXISTS (SELECT 1 FROM dbo.VerificationCodes WHERE UserId = @Customer1UserId AND BookingId = @Booking2Id AND Purpose = N'BookingCompletion' AND CodeHash = N'SEED-CODE-HASH-1')
    INSERT dbo.VerificationCodes (UserId, BookingId, CodeHash, Purpose, Channel, ExpiresAt, Attempts)
    VALUES (@Customer1UserId, @Booking2Id, N'SEED-CODE-HASH-1', N'BookingCompletion', N'Email', DATEADD(hour, 1, GETDATE()), 0);

/* =========================
   COMMIT
   ========================= */
COMMIT TRANSACTION;

PRINT 'HomeFix development seed completed successfully.';
GO
