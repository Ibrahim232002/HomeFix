class ApiConstants {
  /// Runtime-independent build-time configuration.
  ///
  /// Example:
  /// flutter run --dart-define=HOMEFIX_API_URL=http://10.0.2.2:5045
  static const String defaultBaseUrl = String.fromEnvironment(
    'HOMEFIX_API_URL',
    defaultValue: 'http://192.168.1.4:5045',
  );

  static String get baseUrl => defaultBaseUrl;

  static const Duration timeoutDuration = Duration(seconds: 30);

  // Auth endpoints
  static const String register = '/api/Auth/register';
  static const String verifyEmail = '/api/Auth/verify-email';
  static const String login = '/api/Auth/login';
  static const String refresh = '/api/Auth/refresh';
  static const String logout = '/api/Auth/logout';
  static const String me = '/api/Auth/me';
  static const String googleLogin = '/api/Auth/google';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String resetPassword = '/api/Auth/reset-password';

  // Addresses
  static const String addresses = '/api/Addresses';
  static String addressById(int id) => '/api/Addresses/$id';
  static String addressesByCustomer(int customerId) => '/api/Addresses/customer/$customerId';

  // Cities / Governorates
  static const String cities = '/api/Cities';
  static String cityById(int id) => '/api/Cities/$id';
  static String citiesByGovernorate(int governorateId) => '/api/Cities/governorate/$governorateId';
  static const String governorates = '/api/Governorates';
  static String governorateById(int id) => '/api/Governorates/$id';

  // Services / Pricing
  static const String services = '/api/Services';
  static String serviceById(int id) => '/api/Services/$id';
  static const String servicePricings = '/api/ServicePricings';
  static String servicePricingsByService(int serviceId) => '/api/ServicePricings/service/$serviceId';

  // Customer profiles
  static const String customerProfiles = '/api/CustomerProfiles';
  static String customerProfileById(int id) => '/api/CustomerProfiles/$id';
  static String customerProfileByUser(int userId) => '/api/CustomerProfiles/user/$userId';

  // Technician profiles / availability / documents / areas
  static const String technicianProfiles = '/api/TechnicianProfiles';
  static String technicianProfileById(int id) => '/api/TechnicianProfiles/$id';
  static String technicianProfileByUser(int userId) => '/api/TechnicianProfiles/user/$userId';
  static const String activeTechnicianProfiles = '/api/TechnicianProfiles/active';

  static const String technicianAvailabilities = '/api/TechnicianAvailabilities';
  static String technicianAvailabilityById(int id) => '/api/TechnicianAvailabilities/$id';
  static String technicianAvailabilitiesByTechnician(int technicianId) => '/api/TechnicianAvailabilities/technician/$technicianId';

  static const String technicianDocuments = '/api/TechnicianDocuments';
  static String technicianDocumentById(int id) => '/api/TechnicianDocuments/$id';
  static String technicianDocumentsByTechnician(int technicianId) => '/api/TechnicianDocuments/technician/$technicianId';
  static const String pendingTechnicianDocuments = '/api/TechnicianDocuments/pending';

  static const String technicianServiceAreas = '/api/TechnicianServiceAreas';
  static String technicianServiceAreasByTechnician(int technicianId) => '/api/TechnicianServiceAreas/technician/$technicianId';
  static String technicianServiceAreasByCity(int cityId) => '/api/TechnicianServiceAreas/city/$cityId';
  static String deleteTechnicianServiceArea(int technicianId, int cityId) => '/api/TechnicianServiceAreas/$technicianId/$cityId';

  // Service requests / files / history
  static const String serviceRequests = '/api/ServiceRequests';
  static String serviceRequestById(int id) => '/api/ServiceRequests/$id';
  static String serviceRequestsByCustomer(int customerId) => '/api/ServiceRequests/customer/$customerId';
  static const String technicianAvailableRequests = '/api/ServiceRequests/technician-available';

  static const String serviceRequestFiles = '/api/ServiceRequestFiles';
  static String serviceRequestFileById(int id) => '/api/ServiceRequestFiles/$id';
  static String serviceRequestFilesByRequest(int serviceRequestId) => '/api/ServiceRequestFiles/request/$serviceRequestId';

  static const String serviceRequestStatusHistory = '/api/ServiceRequestStatusHistory';
  static String serviceRequestStatusHistoryByRequest(int serviceRequestId) => '/api/ServiceRequestStatusHistory/request/$serviceRequestId';

  // Bookings
  static const String bookings = '/api/Bookings';
  static String bookingById(int id) => '/api/Bookings/$id';
  static String bookingByRequest(int serviceRequestId) => '/api/Bookings/request/$serviceRequestId';
  static String bookingsByTechnician(int technicianId) => '/api/Bookings/technician/$technicianId';
  static const String bookingVerificationCode = '/api/Bookings';
  static String requestBookingVerificationCode(int bookingId) => '/api/Bookings/$bookingId/verification-code';
  static String verifyBookingCode(int bookingId) => '/api/Bookings/$bookingId/verify-code';

  // Payments: only endpoints currently exposed by the backend
  static const String payments = '/api/Payments';
  static String paymentById(int id) => '/api/Payments/$id';
  static String paymentsByRequest(int serviceRequestId) => '/api/Payments/request/$serviceRequestId';
  static String setCashPayment(int serviceRequestId) => '/api/Payments/cash/$serviceRequestId';

  // Reviews
  static const String reviews = '/api/Reviews';
  static String reviewById(int id) => '/api/Reviews/$id';
  static String reviewByRequest(int serviceRequestId) => '/api/Reviews/request/$serviceRequestId';
  static String reviewsByTechnician(int technicianId) => '/api/Reviews/technician/$technicianId';

  // Promo codes / applied user promo codes
  static const String promoCodes = '/api/PromoCodes';
  static String promoCodeById(int id) => '/api/PromoCodes/$id';
  static String promoCodeByCode(String code) => '/api/PromoCodes/code/$code';
  static const String activePromoCodes = '/api/PromoCodes/active';

  static const String userPromoCodes = '/api/UserPromoCodes';
  static String userPromoCodeById(int id) => '/api/UserPromoCodes/$id';
  static String userPromoCodesByRequest(int serviceRequestId) => '/api/UserPromoCodes/request/$serviceRequestId';

  // Wallet / payouts
  static const String technicianWallets = '/api/TechnicianWallets';
  static String technicianWalletById(int id) => '/api/TechnicianWallets/$id';
  static const String myTechnicianWallet = '/api/TechnicianWallets/me';

  static const String walletTransactions = '/api/WalletTransactions';
  static String walletTransactionById(int id) => '/api/WalletTransactions/$id';
  static String walletTransactionsByWallet(int walletId) => '/api/WalletTransactions/wallet/$walletId';

  static const String payouts = '/api/Payouts';
  static String payoutById(int id) => '/api/Payouts/$id';
  static String payoutsByTechnician(int technicianId) => '/api/Payouts/technician/$technicianId';
  static const String myPayouts = '/api/Payouts/me';

  // Conversations / messages
  static const String conversations = '/api/Conversations';
  static String conversationById(int id) => '/api/Conversations/$id';
  static String conversationByRequest(int serviceRequestId) => '/api/Conversations/request/$serviceRequestId';
  static String conversationsByCustomer(int customerId) => '/api/Conversations/customer/$customerId';
  static String conversationsByTechnician(int technicianId) => '/api/Conversations/technician/$technicianId';

  static const String messages = '/api/Messages';
  static String messageById(int id) => '/api/Messages/$id';
  static String messagesByConversation(int conversationId) => '/api/Messages/conversation/$conversationId';

  // Notifications
  static const String notifications = '/api/Notifications/me';
  static String notificationById(int id) => '/api/Notifications/$id';

  // Support
  static const String supportTickets = '/api/SupportTickets';
  static String supportTicketById(int id) => '/api/SupportTickets/$id';
  static String supportTicketsByUser(int userId) => '/api/SupportTickets/user/$userId';
  static String supportTicketsByStatus(String status) => '/api/SupportTickets/status/$status';

  static const String supportMessages = '/api/SupportMessages';
  static String supportMessagesByTicket(int supportTicketId) => '/api/SupportMessages/ticket/$supportTicketId';
}
