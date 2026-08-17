USE HomeFixDb;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

/*
    Removes only the known development/demo data created by the former seed script.
    It targets the dedicated seed.*@homefix.local accounts and SEED* promo codes/tokens.
    Review the row counts before committing in a production-like environment.
*/

DECLARE @SeedUsers TABLE (Id INT PRIMARY KEY);
DECLARE @SeedCustomers TABLE (Id INT PRIMARY KEY);
DECLARE @SeedTechnicians TABLE (Id INT PRIMARY KEY);
DECLARE @SeedRequests TABLE (Id INT PRIMARY KEY);
DECLARE @SeedBookings TABLE (Id INT PRIMARY KEY);
DECLARE @SeedConversations TABLE (Id INT PRIMARY KEY);
DECLARE @SeedTickets TABLE (Id INT PRIMARY KEY);
DECLARE @SeedWallets TABLE (Id INT PRIMARY KEY);

INSERT INTO @SeedUsers (Id)
SELECT Id
FROM dbo.Users
WHERE Email LIKE 'seed.%@homefix.local';

INSERT INTO @SeedCustomers (Id)
SELECT Id
FROM dbo.CustomerProfiles
WHERE UserId IN (SELECT Id FROM @SeedUsers);

INSERT INTO @SeedTechnicians (Id)
SELECT Id
FROM dbo.TechnicianProfiles
WHERE UserId IN (SELECT Id FROM @SeedUsers);

INSERT INTO @SeedRequests (Id)
SELECT Id
FROM dbo.ServiceRequests
WHERE CustomerId IN (SELECT Id FROM @SeedCustomers);

INSERT INTO @SeedBookings (Id)
SELECT Id
FROM dbo.Bookings
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR TechnicianId IN (SELECT Id FROM @SeedTechnicians);

INSERT INTO @SeedConversations (Id)
SELECT Id
FROM dbo.Conversations
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR CustomerId IN (SELECT Id FROM @SeedCustomers)
   OR TechnicianId IN (SELECT Id FROM @SeedTechnicians);

INSERT INTO @SeedTickets (Id)
SELECT Id
FROM dbo.SupportTickets
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR ServiceRequestId IN (SELECT Id FROM @SeedRequests);

INSERT INTO @SeedWallets (Id)
SELECT Id
FROM dbo.TechnicianWallets
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

SELECT 'Seed users' AS Item, COUNT(*) AS RowCount FROM @SeedUsers;
SELECT 'Seed customers' AS Item, COUNT(*) AS RowCount FROM @SeedCustomers;
SELECT 'Seed technicians' AS Item, COUNT(*) AS RowCount FROM @SeedTechnicians;
SELECT 'Seed requests' AS Item, COUNT(*) AS RowCount FROM @SeedRequests;
SELECT 'Seed bookings' AS Item, COUNT(*) AS RowCount FROM @SeedBookings;
SELECT 'Seed conversations' AS Item, COUNT(*) AS RowCount FROM @SeedConversations;
SELECT 'Seed tickets' AS Item, COUNT(*) AS RowCount FROM @SeedTickets;

DELETE FROM dbo.PaymentAttempts
WHERE PaymentId IN
(
    SELECT Id FROM dbo.Payments
    WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
);

DELETE FROM dbo.Messages
WHERE ConversationId IN (SELECT Id FROM @SeedConversations)
   OR SenderId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.SupportMessages
WHERE SupportTicketId IN (SELECT Id FROM @SeedTickets)
   OR SenderId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.WalletTransactions
WHERE WalletId IN (SELECT Id FROM @SeedWallets)
   OR ServiceRequestId IN (SELECT Id FROM @SeedRequests);

DELETE FROM dbo.Notifications
WHERE UserId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.VerificationCodes
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR BookingId IN (SELECT Id FROM @SeedBookings);

DELETE FROM dbo.EmailVerificationTokens
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR Token LIKE 'SEED-%';

DELETE FROM dbo.PasswordResetTokens
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR Token LIKE 'SEED-%';

DELETE FROM dbo.RefreshTokens
WHERE UserId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.UserDevices
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR DeviceToken LIKE 'SEED-%';

DELETE FROM dbo.ExternalLogins
WHERE UserId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.UserPromoCodes
WHERE UserId IN (SELECT Id FROM @SeedUsers)
   OR ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR PromoCodeId IN (SELECT Id FROM dbo.PromoCodes WHERE Code LIKE 'SEED%');

DELETE FROM dbo.ServiceRequestStatusHistory
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR ChangedByUserId IN (SELECT Id FROM @SeedUsers);

DELETE FROM dbo.Reviews
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR CustomerId IN (SELECT Id FROM @SeedCustomers)
   OR TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.Payments
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests);

DELETE FROM dbo.Payouts
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.ServiceRequestFiles
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests);

DELETE FROM dbo.ServiceRequestOffers
WHERE ServiceRequestId IN (SELECT Id FROM @SeedRequests)
   OR TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.Conversations
WHERE Id IN (SELECT Id FROM @SeedConversations);

DELETE FROM dbo.SupportTickets
WHERE Id IN (SELECT Id FROM @SeedTickets);

DELETE FROM dbo.Bookings
WHERE Id IN (SELECT Id FROM @SeedBookings);

DELETE FROM dbo.ServiceRequests
WHERE Id IN (SELECT Id FROM @SeedRequests);

DELETE FROM dbo.Addresses
WHERE CustomerId IN (SELECT Id FROM @SeedCustomers);

DELETE FROM dbo.TechnicianServiceAreas
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.TechnicianServices
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.TechnicianAvailability
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.TechnicianDocuments
WHERE TechnicianId IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.TechnicianWallets
WHERE Id IN (SELECT Id FROM @SeedWallets);

DELETE FROM dbo.CustomerProfiles
WHERE Id IN (SELECT Id FROM @SeedCustomers);

DELETE FROM dbo.TechnicianProfiles
WHERE Id IN (SELECT Id FROM @SeedTechnicians);

DELETE FROM dbo.PromoCodes
WHERE Code LIKE 'SEED%';

DELETE FROM dbo.Users
WHERE Id IN (SELECT Id FROM @SeedUsers);

COMMIT TRANSACTION;
GO
