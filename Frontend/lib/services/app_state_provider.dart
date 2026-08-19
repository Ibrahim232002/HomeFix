import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
import '../models/service_request_model.dart';
import '../models/booking_model.dart';
import '../models/technician_profile_model.dart';
import '../models/technician_document_model.dart';
import '../models/technician_service_area_model.dart';
import '../models/wallet_model.dart';
import '../models/chat_model.dart';
import '../models/notification_model.dart';
import '../models/address_model.dart';
import '../models/review_model.dart';
import '../models/promo_code_model.dart';
import '../models/payment_model.dart';
import '../models/offer_model.dart';
import '../repositories/service_repository.dart';
import '../repositories/service_category_repository.dart';
import '../repositories/service_request_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/technician_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/promo_code_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/service_request_offer_repository.dart';
import '../models/api_dtos.dart';

class AppStateProvider extends ChangeNotifier {
  final IServiceRepository _serviceRepo = ServiceRepository();
  final IServiceCategoryRepository _serviceCategoryRepo = ServiceCategoryRepository();
  final IServiceRequestRepository _requestRepo = ServiceRequestRepository();
  final IBookingRepository _bookingRepo = BookingRepository();
  final IChatRepository _chatRepo = ChatRepository();
  final ITechnicianRepository _techRepo = TechnicianRepository();
  final IWalletRepository _walletRepo = WalletRepository();
  final IUserRepository _userRepo = UserRepository();
  final IPromoCodeRepository _promoRepo = PromoCodeRepository();
  final IPaymentRepository _paymentRepo = PaymentRepository();
  final IReviewRepository _reviewRepo = ReviewRepository();
  final ServiceRequestOfferRepository _offerRepo = ServiceRequestOfferRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoadingPublic = false;
  bool _isLoadingCategoryServices = false;
  String? _errorMessage;
  String? _apiError;
  String? _categoryError;
  int _customerNavIndex = 0;
  int _technicianNavIndex = 0;
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  List<ServiceRequestModel> _customerRequests = [];
  List<ServiceRequestModel> _availableTechRequests = [];
  List<BookingModel> _bookings = [];
  List<TechnicianProfileModel> _technicians = [];
  List<ConversationModel> _conversations = [];
  List<NotificationModel> _notifications = [];
  List<AddressModel> _savedAddresses = [];
  List<TechnicianDocumentModel> _technicianDocuments = [];
  List<PaymentModel> _payments = [];
  List<ServiceRequestOfferModel> _customerOffers = [];
  List<ServiceRequestOfferModel> _technicianOffers = [];
  PaymentModel? _activePayment;
  WalletModel? _wallet;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  PromoCodeModel? _appliedPromo;
  TechnicianProfileModel? _currentTechProfile;
  List<TechnicianServiceAreaModel> _serviceAreas = [];
  List<GovernorateDto> _governorates = [];

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.customer;
  bool get isCustomer => currentRole == UserRole.customer;
  bool get isTechnician => currentRole == UserRole.technician;
  bool get isLoading => _isLoading;
  bool get isLoadingPublic => _isLoadingPublic || _isLoadingCategoryServices;
  String? get errorMessage => _errorMessage;
  String? get apiError => _categoryError ?? _apiError;
  int get customerNavIndex => _customerNavIndex;
  int get technicianNavIndex => _technicianNavIndex;
  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get services => _services;
  List<ServiceRequestModel> get customerRequests => _customerRequests;
  List<ServiceRequestModel> get availableTechRequests => _availableTechRequests;
  List<BookingModel> get bookings => _bookings;
  List<TechnicianProfileModel> get technicians => _technicians;
  List<ConversationModel> get conversations => _conversations;
  List<NotificationModel> get notifications => _notifications;
  List<AddressModel> get savedAddresses => _savedAddresses;
  List<TechnicianDocumentModel> get technicianDocuments => _technicianDocuments;
  List<PaymentModel> get payments => _payments;
  PaymentModel? get activePayment => _activePayment;
  WalletModel? get wallet => _wallet;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  PromoCodeModel? get appliedPromo => _appliedPromo;
  TechnicianProfileModel? get currentTechProfile => _currentTechProfile;
  List<ServiceRequestOfferModel> get customerOffers => _customerOffers;
  List<ServiceRequestOfferModel> get technicianOffers => _technicianOffers;
  List<TechnicianServiceAreaModel> get serviceAreas => _serviceAreas;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  AppStateProvider() { _loadPublicData(); }

  Future<void> _loadPublicData() async {
    _isLoadingPublic = true; _categoryError = null; _apiError = null; notifyListeners();
    try { _categories = await _serviceCategoryRepo.getCategories(); _services = await _serviceRepo.getServices(); _technicians = await _techRepo.getTechnicians(); }
    catch (e) { _apiError = e.toString(); }
    finally { _isLoadingPublic = false; notifyListeners(); }
  }
  Future<void> refreshPublicData() async => _loadPublicData();

  Future<void> login(String email, String password, UserRole role) async { _isLoading = true; _errorMessage = null; notifyListeners(); try { _currentUser = await _userRepo.login(email, password, role); if (_currentUser?.role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); } finally { _isLoading = false; notifyListeners(); } }
  Future<void> register({required String fullName, required String email, required String phoneNumber, required String password, required UserRole role}) async { _isLoading = true; _errorMessage = null; notifyListeners(); try { _currentUser = await _userRepo.register(RegisterRequest(fullName: fullName, email: email, phoneNumber: phoneNumber, password: password, role: role == UserRole.technician ? 'Technician' : 'Customer')); if (_currentUser?.role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); } finally { _isLoading = false; notifyListeners(); } }
  Future<void> loginWithPhone(String phone, String otp, UserRole role) async { _isLoading = true; notifyListeners(); try { _currentUser = await _userRepo.loginWithPhone(phone, otp, role); if (role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString(); } finally { _isLoading = false; notifyListeners(); } }

  void logout() { _currentUser = null; _errorMessage = null; _apiError = null; _categoryError = null; _customerNavIndex = 0; _technicianNavIndex = 0; _selectedCategoryId = 'all'; _searchQuery = ''; _appliedPromo = null; _currentTechProfile = null; _customerRequests = []; _availableTechRequests = []; _bookings = []; _conversations = []; _notifications = []; _savedAddresses = []; _technicianDocuments = []; _payments = []; _customerOffers = []; _technicianOffers = []; _serviceAreas = []; _governorates = []; _activePayment = null; _wallet = null; notifyListeners(); }
  void setCustomerNavIndex(int index) { _customerNavIndex = index; notifyListeners(); }
  void setTechnicianNavIndex(int index) { _technicianNavIndex = index; notifyListeners(); }

  Future<void> _loadInitialData() async { try { _services = await _serviceRepo.getServices(); _technicians = await _techRepo.getTechnicians(); if (_currentUser != null) { if (isCustomer) { _customerRequests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); _savedAddresses = await _userRepo.getUserAddresses(_currentUser!.id); } else { _availableTechRequests = await _requestRepo.getAvailableRequestsForTechnicians(); _currentTechProfile = await _techRepo.getTechnicianById(_currentUser!.id); final techId = _currentTechProfile?.id ?? _currentUser!.id; _bookings = await _bookingRepo.getBookingsByTechnician(techId); _wallet = await _walletRepo.getWalletByTechnician(techId); _serviceAreas = await _techRepo.getServiceAreas(int.tryParse(techId) ?? 0); _technicianOffers = await _offerRepo.getMyOffers(); } _conversations = await _chatRepo.getConversations(_currentUser!.id); _notifications = await _userRepo.getUserNotifications(_currentUser!.id); } } catch (e) { _apiError = e.toString(); } notifyListeners(); }

  Future<List<GovernorateDto>> loadGovernoratesForTechnician() async { if (_governorates.isNotEmpty) return _governorates; final client = ApiClient(); final response = await client.get(ApiConstants.governorates); if (response is List) _governorates = response.map((e) => GovernorateDto.fromJson(e as Map<String, dynamic>)).toList(); return _governorates; }
  Future<List<CityDto>> loadCitiesForTechnician(int governorateId) async { final client = ApiClient(); final response = await client.get(ApiConstants.citiesByGovernorate(governorateId)); if (response is List) return response.map((e) => CityDto.fromJson(e as Map<String, dynamic>)).toList(); return []; }
  Future<String> getCityName(int cityId) async { final client = ApiClient(); try { final response = await client.get(ApiConstants.cityById(cityId)); return CityDto.fromJson(response as Map<String, dynamic>).name ?? 'مدينة $cityId'; } catch (_) { return 'مدينة $cityId'; } }
  Future<void> selectCategory(String categoryId) async { _selectedCategoryId = categoryId; _categoryError = null; _isLoadingCategoryServices = true; notifyListeners(); try { if (categoryId == 'all') _services = await _serviceRepo.getServices(); else { final categoryName = _categories.firstWhere((c) => c.id == categoryId, orElse: () => _categories.first).nameAr; _services = await _serviceRepo.getServicesByCategory(categoryId, categoryNameAr: categoryName); } } catch (e) { _services = []; _categoryError = e.toString(); } finally { _isLoadingCategoryServices = false; notifyListeners(); } }
  void setSearchQuery(String query) async { _searchQuery = query; _services = await _serviceRepo.searchServices(query); notifyListeners(); }
  Future<void> applyPromoCode(String code) async { try { final dto = await _promoRepo.getPromoCodeByCode(code); if (dto != null && dto.isActive) _appliedPromo = PromoCodeModel(code: dto.code ?? code, title: dto.code ?? 'كود خصم', discount: '${dto.discountValue.toStringAsFixed(0)}%', maxDiscount: 'خصم ${dto.discountValue}', description: 'كود ترويجي', expiry: dto.endDate, discountPercentage: dto.discountValue, maxDiscountAmount: dto.discountValue); else _appliedPromo = null; } catch (_) { _appliedPromo = null; } notifyListeners(); }
  void removePromoCode() { _appliedPromo = null; notifyListeners(); }

  Future<ServiceRequestModel> createServiceRequest({required ServiceModel service, required AddressModel address, required String problemDescription, required String preferredDate, required String preferredTime, List<ServiceRequestFileModel>? files}) async { if (_currentUser == null) throw Exception('User not authenticated'); final requestToCreate = ServiceRequestModel(id: 'req-${DateTime.now().millisecondsSinceEpoch}', serviceId: service.id, serviceNameAr: service.nameAr, categoryNameAr: service.categoryNameAr, customerId: _currentUser!.id, customerName: _currentUser!.fullName, customerPhone: _currentUser!.phoneNumber, address: address, problemDescription: problemDescription, preferredDate: preferredDate, preferredTime: preferredTime, files: files ?? [], status: ServiceRequestStatus.pending, estimatedPriceMin: service.pricing.minPrice, estimatedPriceMax: service.pricing.maxPrice, createdAt: 'الآن', statusHistory: [ServiceRequestStatusHistoryModel(status: ServiceRequestStatus.pending, timestamp: 'الآن', updatedBy: _currentUser!.fullName)]); final newReq = await _requestRepo.createRequest(requestToCreate); _customerRequests.insert(0, newReq); notifyListeners(); return newReq; }
  Future<void> cancelRequest(String requestId, String reason) async { await _requestRepo.cancelRequest(requestId, reason); if (_currentUser != null) _customerRequests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); if (isTechnician) _availableTechRequests = await _requestRepo.getAvailableRequestsForTechnicians(); notifyListeners(); }

  Future<void> submitTechnicianOffer({required ServiceRequestModel request, required double proposedPrice, String? technicianNote}) async { final requestId = int.tryParse(request.id); if (requestId == null || requestId <= 0) throw Exception('معرف الطلب غير صالح'); final offer = await _offerRepo.createOffer(serviceRequestId: requestId, proposedPrice: proposedPrice, technicianNote: technicianNote); _technicianOffers.insert(0, offer); _availableTechRequests.removeWhere((r) => r.id == request.id); notifyListeners(); }
  Future<void> loadOffersForCustomerRequest(String requestId) async { final id = int.tryParse(requestId); if (id == null || id <= 0) { _customerOffers = []; notifyListeners(); return; } _customerOffers = await _offerRepo.getOffersForRequest(id); notifyListeners(); }
  Future<void> acceptCustomerOffer(String offerId, String requestId) async { final id = int.tryParse(offerId); if (id == null || id <= 0) throw Exception('معرف العرض غير صالح'); await _offerRepo.acceptOffer(id); if (_currentUser != null) _customerRequests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); _customerOffers = await _offerRepo.getOffersForRequest(int.tryParse(requestId) ?? 0); notifyListeners(); }
  Future<void> rejectCustomerOffer(String offerId, String requestId) async { final id = int.tryParse(offerId); if (id == null || id <= 0) throw Exception('معرف العرض غير صالح'); await _offerRepo.rejectOffer(id); _customerOffers = await _offerRepo.getOffersForRequest(int.tryParse(requestId) ?? 0); notifyListeners(); }

  Future<void> loadServiceAreas() async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId > 0) { _serviceAreas = await _techRepo.getServiceAreas(techId); notifyListeners(); } }
  Future<void> addTechnicianServiceArea(int cityId) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); await _techRepo.addServiceArea(techId, cityId); await loadServiceAreas(); }
  Future<void> removeTechnicianServiceArea(int cityId) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); await _techRepo.deleteServiceArea(techId, cityId); await loadServiceAreas(); }
  Future<void> updateTechnicianCurrentLocation(double latitude, double longitude) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); final dto = await _techRepo.updateApiTechnicianProfile(techId, UpdateTechnicianProfileRequest(currentLatitude: latitude, currentLongitude: longitude)); _currentTechProfile = _currentTechProfile?.copyWith(currentLatitude: dto.currentLatitude, currentLongitude: dto.currentLongitude); notifyListeners(); }
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async { await _bookingRepo.updateBookingStatus(bookingId, status); if (_currentUser != null) _bookings = await _bookingRepo.getBookingsByTechnician(_currentUser!.id); notifyListeners(); }
  Future<void> toggleTechnicianAvailability() async { if (_currentUser == null || _currentTechProfile == null) return; final newStatus = !_currentTechProfile!.isAvailable; await _techRepo.updateAvailability(_currentTechProfile!.id, newStatus); _currentTechProfile = _currentTechProfile!.copyWith(isAvailable: newStatus); notifyListeners(); }
  Future<MessageModel> sendMessage(String conversationId, String text, {String? attachmentUrl}) async { if (_currentUser == null) throw Exception('Not logged in'); final msg = await _chatRepo.sendMessage(conversationId: conversationId, sender: _currentUser!, text: text, attachmentUrl: attachmentUrl); _conversations = await _chatRepo.getConversations(_currentUser!.id); notifyListeners(); return msg; }
  Future<ConversationModel> startConversationWithTechnician({required TechnicianProfileModel technician, String? serviceNameAr, String? requestId}) async { if (_currentUser == null) throw Exception('Not logged in'); final conv = await _chatRepo.getOrCreateConversation(customerId: _currentUser!.id, customerName: _currentUser!.fullName, customerAvatar: _currentUser!.avatarUrl, technicianId: technician.userId, technicianName: technician.fullName, technicianAvatar: technician.avatarUrl, serviceNameAr: serviceNameAr, requestId: requestId); _conversations = await _chatRepo.getConversations(_currentUser!.id); notifyListeners(); return conv; }
  Future<void> addAddress(AddressModel address) async { final added = await _userRepo.addAddress(address); _savedAddresses.add(added); notifyListeners(); }
  Future<void> requestWithdrawal(double amount, String iban) async { if (_currentUser == null) return; await _walletRepo.requestWithdrawal(_currentUser!.id, amount, iban); _wallet = await _walletRepo.getWalletByTechnician(_currentUser!.id); notifyListeners(); }
  void markNotificationAsRead(String id) { _userRepo.markNotificationAsRead(id); final index = _notifications.indexWhere((n) => n.id == id); if (index != -1) { _notifications[index] = _notifications[index].copyWith(isRead: true); notifyListeners(); } }
  Future<void> markAllNotificationsAsRead() async { for (var i = 0; i < _notifications.length; i++) { if (!_notifications[i].isRead) { _notifications[i] = _notifications[i].copyWith(isRead: true); _userRepo.markNotificationAsRead(_notifications[i].id); } } notifyListeners(); }
  Future<void> submitReview({required String requestId, required String technicianId, required double rating, String? comment, String? serviceNameAr}) async { if (_currentUser == null) return; await _reviewRepo.createReview(CreateReviewRequest(serviceRequestId: int.tryParse(requestId) ?? 0, customerId: int.tryParse(_currentUser!.id) ?? 0, technicianId: int.tryParse(technicianId) ?? 0, rating: rating.toInt(), comment: comment)); notifyListeners(); }
  Future<void> uploadDocument({required String titleAr, required String titleEn, required String documentType, String? documentNumber, String? fileUrl}) async { if (_currentUser == null) return; final techId = int.tryParse(_currentTechProfile?.id ?? _currentUser!.id) ?? 0; if (techId == 0) return; final docDto = await _techRepo.uploadDocument(CreateTechnicianDocumentRequest(technicianId: techId, documentType: documentType, documentUrl: fileUrl ?? 'https://example.com/doc.pdf')); _technicianDocuments.add(TechnicianDocumentModel(id: docDto.id.toString(), technicianId: docDto.technicianId.toString(), titleAr: titleAr, titleEn: titleEn, documentType: docDto.documentType ?? documentType, documentNumber: documentNumber, fileUrl: docDto.documentUrl ?? '', status: DocumentStatus.fromString(docDto.status ?? 'Pending'), submittedAt: docDto.uploadedAt.isNotEmpty ? docDto.uploadedAt : 'الآن')); notifyListeners(); }
  Future<List<PaymentModel>> loadPaymentsForRequest(String requestId) async { final reqId = int.tryParse(requestId) ?? 0; if (reqId == 0) return []; try { final dtoList = await _paymentRepo.getPaymentsByRequestId(reqId); final mapped = dtoList.map((d) => PaymentModel.fromDto(d)).toList(); _payments = mapped; notifyListeners(); return mapped; } catch (_) { return []; } }
  Future<InitiatePaymentResponse> initiatePayment({required String serviceRequestId, required PaymentMethodType method, String? walletPhoneNumber, String paymentType = 'FullService'}) async { final reqId = int.tryParse(serviceRequestId) ?? 0; if (reqId == 0) throw Exception('معرف طلب الخدمة غير صالح'); _isLoading = true; _errorMessage = null; notifyListeners(); try { final response = await _paymentRepo.initiatePayment(InitiatePaymentRequest(serviceRequestId: reqId, paymentMethod: method.nameStr, walletPhoneNumber: walletPhoneNumber, paymentType: paymentType)); _activePayment = PaymentModel.fromInitiateResponse(response, serviceRequestId, response.amount); _isLoading = false; notifyListeners(); return response; } catch (e) { _isLoading = false; _errorMessage = e.toString(); notifyListeners(); rethrow; } }
  Future<VerifyPaymentResponse> verifyPayment(int paymentId) async { _isLoading = true; notifyListeners(); try { final verifyResp = await _paymentRepo.verifyPayment(paymentId); if (_activePayment != null && _activePayment!.id == paymentId.toString()) _activePayment = _activePayment!.copyWith(status: PaymentStatusTypeExtension.fromString(verifyResp.status), transactionReference: verifyResp.transactionReference, paidAt: verifyResp.paidAt); if (verifyResp.isSuccess && _currentUser != null) _customerRequests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); _isLoading = false; notifyListeners(); return verifyResp; } catch (e) { _isLoading = false; notifyListeners(); rethrow; } }
  Future<PaymentDto> selectCashOnDelivery(String serviceRequestId) async { final reqId = int.tryParse(serviceRequestId) ?? 0; if (reqId == 0) throw Exception('معرف طلب الخدمة غير صالح'); _isLoading = true; notifyListeners(); try { final dto = await _paymentRepo.setCashPayment(reqId); _activePayment = PaymentModel.fromDto(dto); if (_currentUser != null) _customerRequests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); _isLoading = false; notifyListeners(); return dto; } catch (e) { _isLoading = false; _errorMessage = e.toString(); notifyListeners(); rethrow; } }
}
