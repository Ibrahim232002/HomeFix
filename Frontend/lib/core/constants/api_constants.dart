class ApiConstants {
  static const String defaultBaseUrl = 'http://192.168.1.4:5045';
  static String baseUrl = defaultBaseUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';
  static const String refresh = '/api/Auth/refresh';
  static const String logout = '/api/Auth/logout';
  static const String me = '/api/Auth/me';

  static const String addresses = '/api/Addresses';
  static String addressById(int id) => '/api/Addresses/$id';
  static String addressesByCustomer(int customerId) => '/api/Addresses/customer/$customerId';

  static const String cities = '/api/Cities';
  static String cityById(int id) => '/api/Cities/$id';
  static String citiesByGovernorate(int governorateId) => '/api/Cities/governorate/$governorateId';
  static const String governorates = '/api/Governorates';
  static String governorateById(int id) => '/api/Governorates/$id';

  static const String services = '/api/Services';
  static String serviceById(int id) => '/api/Services/$id';
  static String servicesByCategory(int categoryId) => '/api/Services/category/$categoryId';
  static const String serviceCategories = '/api/ServiceCategories';
  static String serviceCategoryById(int id) => '/api/ServiceCategories/$id';
  static const String servicePricings = '/api/ServicePricings';
  static String servicePricingsByService(int serviceId) => '/api/ServicePricings/service/$serviceId';

  static const String customerProfiles = '/api/CustomerProfiles';
  static String customerProfileById(int id) => '/api/CustomerProfiles/$id';
  static String customerProfileByUser(int userId) => '/api/CustomerProfiles/user/$userId';

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

  static const String serviceRequests = '/api/ServiceRequests';
  static String serviceRequestById(int id) => '/api/ServiceRequests/$id';
  static String cancelServiceRequest(int id) => '/api/ServiceRequests/$id/cancel';
  static String serviceRequestsByCustomer(int customerId) => '/api/ServiceRequests/customer/$customerId';
  static String serviceRequestsByStatus(String status) => '/api/ServiceRequests/status/$status';
  static const String serviceRequestFiles = '/api/ServiceRequestFiles';
  static String serviceRequestFileById(int id) => '/api/ServiceRequestFiles/$id';
  static String serviceRequestFilesByRequest(int serviceRequestId) => '/api/ServiceRequestFiles/request/$serviceRequestId';
  static const String serviceRequestStatusHistory = '/api/ServiceRequestStatusHistory';
  static String serviceRequestStatusHistoryByRequest(int serviceRequestId) => '/api/ServiceRequestStatusHistory/request/$serviceRequestId';

  static const String serviceRequestOffers = '/api/ServiceRequestOffers';
  static String serviceRequestOffersByRequest(int requestId) => '/api/ServiceRequestOffers/request/$requestId';
  static const String myServiceRequestOffers = '/api/ServiceRequestOffers/mine';
  static String serviceRequestOffersByTechnician(int technicianId) => '/api/ServiceRequestOffers/technician/$technicianId';
  static String acceptServiceRequestOffer(int offerId) => '/api/ServiceRequestOffers/$offerId/accept';
  static String rejectServiceRequestOffer(int offerId) => '/api/ServiceRequestOffers/$offerId/reject';

  static const String bookings = '/api/Bookings';
  static String bookingById(int id) => '/api/Bookings/$id';
  static String bookingByRequest(int serviceRequestId) => '/api/Bookings/request/$serviceRequestId';
  static String bookingsByTechnician(int technicianId) => '/api/Bookings/technician/$technicianId';
  static String bookingTransition(int id) => '/api/Bookings/$id/transition';

  static const String payments = '/api/Payments';
  static String paymentById(int id) => '/api/Payments/$id';
  static String paymentsByRequest(int serviceRequestId) => '/api/Payments/request/$serviceRequestId';
  static const String initiatePayment = '/api/Payments/initiate';
  static String verifyPayment(int paymentId) => '/api/Payments/verify/$paymentId';
  static String inquirePaymentByReference(String reference) => '/api/Payments/inquire/$reference';
  static String setCashPayment(int serviceRequestId) => '/api/Payments/cash/$serviceRequestId';
  static const String paymobWebhook = '/api/Payments/webhook/paymob';

  static const String reviews = '/api/Reviews';
  static String reviewById(int id) => '/api/Reviews/$id';
  static String reviewByRequest(int serviceRequestId) => '/api/Reviews/request/$serviceRequestId';
  static String reviewsByTechnician(int technicianId) => '/api/Reviews/technician/$technicianId';

  static const String promoCodes = '/api/PromoCodes';
  static String promoCodeById(int id) => '/api/PromoCodes/$id';
  static String promoCodeByCode(String code) => '/api/PromoCodes/code/$code';
  static const String activePromoCodes = '/api/PromoCodes/active';
  static const String userPromoCodes = '/api/UserPromoCodes';
  static String userPromoCodeById(int id) => '/api/UserPromoCodes/$id';
  static String userPromoCodesByRequest(int serviceRequestId) => '/api/UserPromoCodes/request/$serviceRequestId';
  static String userPromoCodesByUser(int userId) => '/api/UserPromoCodes/user/$userId';

  static const String technicianWallets = '/api/TechnicianWallets';
  static String technicianWalletById(int id) => '/api/TechnicianWallets/$id';
  static String technicianWalletByTechnician(int id) => '/api/TechnicianWallets/technician/$id';
  static const String walletTransactions = '/api/WalletTransactions';
  static String walletTransactionById(int id) => '/api/WalletTransactions/$id';
  static String walletTransactionsByWallet(int id) => '/api/WalletTransactions/wallet/$id';
  static const String payouts = '/api/Payouts';
  static String payoutById(int id) => '/api/Payouts/$id';
  static String payoutsByTechnician(int id) => '/api/Payouts/technician/$id';

  static const String conversations = '/api/Conversations';
  static String conversationById(int id) => '/api/Conversations/$id';
  static String conversationByRequest(int id) => '/api/Conversations/request/$id';
  static String conversationsByCustomer(int id) => '/api/Conversations/customer/$id';
  static String conversationsByTechnician(int id) => '/api/Conversations/technician/$id';
  static const String messages = '/api/Messages';
  static String messageById(int id) => '/api/Messages/$id';
  static String messagesByConversation(int id) => '/api/Messages/conversation/$id';

  static const String notifications = '/api/Notifications';
  static String notificationById(int id) => '/api/Notifications/$id';
  static String notificationsByUser(int id) => '/api/Notifications/user/$id';

  static const String supportTickets = '/api/SupportTickets';
  static String supportTicketById(int id) => '/api/SupportTickets/$id';
  static String supportTicketsByUser(int id) => '/api/SupportTickets/user/$id';
  static String supportTicketsByStatus(String status) => '/api/SupportTickets/status/$status';
  static const String supportMessages = '/api/SupportMessages';
  static String supportMessagesByTicket(int id) => '/api/SupportMessages/ticket/$id';
}
