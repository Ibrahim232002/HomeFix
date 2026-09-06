import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/constants/api_constants.dart';
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
import '../models/inspection_model.dart';
import '../models/service_quote_model.dart';
import '../repositories/service_repository.dart';
import '../repositories/auth_repository.dart';
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
import '../repositories/inspection_repository.dart';
import '../repositories/service_quote_repository.dart';
import '../models/api_dtos.dart';

class AppStateProvider extends ChangeNotifier {
  final IServiceRepository _serviceRepo = ServiceRepository();
  final AuthRepository _authRepo = AuthRepository();
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
  final IInspectionRepository _inspectionRepo = InspectionRepository();
  final IServiceQuoteRepository _serviceQuoteRepo = ServiceQuoteRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isRestoringSession = true;
  bool _isLoadingPublic = false;
  bool _isLoadingCategoryServices = false;
  bool _publicDataLoadSucceeded = false;
  Future<void>? _publicDataFuture;
  String? _errorMessage;
  String? _apiError;
  String? _categoryError;
  int _customerNavIndex = 0;
  int _technicianNavIndex = 0;
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  List<ServiceRequestModel> _customerRequests = [];
  List<ServiceRequestModel> _availableTechRequests = [];
  bool _isLoadingAvailableTechRequests = false;
  String? _availableTechRequestsError;
  List<BookingModel> _bookings = [];
  List<TechnicianProfileModel> _technicians = [];
  List<ConversationModel> _conversations = [];
  List<NotificationModel> _notifications = [];
  List<AddressModel> _savedAddresses = [];
  List<TechnicianDocumentModel> _technicianDocuments = [];
  List<PaymentModel> _payments = [];
  List<ServiceRequestOfferModel> _customerOffers = [];
  List<ServiceRequestOfferModel> _technicianOffers = [];
  List<InspectionModel> _customerInspections = [];
  List<InspectionModel> _technicianInspections = [];
  List<ServiceQuoteModel> _serviceQuotes = [];
  PaymentModel? _activePayment;
  WalletModel? _wallet;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  PromoCodeModel? _appliedPromo;
  TechnicianProfileModel? _currentTechProfile;
  List<TechnicianServiceAreaModel> _serviceAreas = [];
  List<GovernorateDto> _governorates = [];
  bool _governoratesLoaded = false;
  Future<List<GovernorateDto>>? _governoratesFuture;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isRestoringSession => _isRestoringSession;
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
  bool get isLoadingAvailableTechRequests => _isLoadingAvailableTechRequests;
  String? get availableTechRequestsError => _availableTechRequestsError;
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
  List<InspectionModel> get customerInspections => _customerInspections;
  List<InspectionModel> get technicianInspections => _technicianInspections;
  List<ServiceQuoteModel> get serviceQuotes => _serviceQuotes;
  List<TechnicianServiceAreaModel> get serviceAreas => _serviceAreas;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  AppStateProvider() {
    _publicDataFuture = _loadPublicData();
    unawaited(_restoreSession());
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _authRepo.restoreSession();
      if (user != null) {
        _currentUser = user;
        if (user.role == UserRole.technician) {
          _technicianNavIndex = 0;
        } else {
          _customerNavIndex = 0;
        }
        await _loadInitialData();
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<void> _loadPublicData() async {
    _isLoadingPublic = true;
    _categoryError = null;
    _apiError = null;
    _publicDataLoadSucceeded = false;
    notifyListeners();

    var categoriesLoaded = false;
    var servicesLoaded = false;
    var techniciansLoaded = false;
    final errors = <String>[];

    try {
      _categories = await _serviceCategoryRepo.getCategories();
      categoriesLoaded = true;
    } catch (e) {
      _categoryError = e.toString();
      errors.add(e.toString());
    }

    try {
      _services = await _serviceRepo.getServices(includePricing: false);
      servicesLoaded = true;
    } catch (e) {
      errors.add(e.toString());
    }

    try {
      _technicians = await _techRepo.getTechnicians();
      techniciansLoaded = true;
    } catch (e) {
      errors.add(e.toString());
    }

    if (errors.isNotEmpty) {
      _apiError = errors.join('\n');
    }

    _publicDataLoadSucceeded =
        categoriesLoaded && servicesLoaded && techniciansLoaded;

    _isLoadingPublic = false;
    notifyListeners();
  }

  Future<void> refreshPublicData() {
    _publicDataFuture = _loadPublicData();
    return _publicDataFuture!;
  }

  Future<void> login(String email, String password, UserRole role) async { _isLoading = true; _errorMessage = null; notifyListeners(); try { _currentUser = await _userRepo.login(email, password, role); if (_currentUser?.role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); } finally { _isLoading = false; notifyListeners(); } }
  Future<void> register({required String fullName, required String email, required String phoneNumber, required String password, required UserRole role}) async { _isLoading = true; _errorMessage = null; notifyListeners(); try { _currentUser = await _userRepo.register(RegisterRequest(fullName: fullName, email: email, phoneNumber: phoneNumber, password: password, role: role == UserRole.technician ? 'Technician' : 'Customer')); if (_currentUser?.role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); } finally { _isLoading = false; notifyListeners(); } }
  Future<void> loginWithPhone(String phone, String otp, UserRole role) async { _isLoading = true; notifyListeners(); try { _currentUser = await _userRepo.loginWithPhone(phone, otp, role); if (role == UserRole.technician) _technicianNavIndex = 0; else _customerNavIndex = 0; await _loadInitialData(); } catch (e) { _errorMessage = e.toString(); } finally { _isLoading = false; notifyListeners(); } }

  Future<void> logout() async { await _authRepo.logout(); _currentUser = null; _errorMessage = null; _apiError = null; _categoryError = null; _customerNavIndex = 0; _technicianNavIndex = 0; _selectedCategoryId = 'all'; _searchQuery = ''; _appliedPromo = null; _currentTechProfile = null; _customerRequests = []; _availableTechRequests = []; _bookings = []; _conversations = []; _notifications = []; _savedAddresses = []; _technicianDocuments = []; _payments = []; _customerOffers = []; _technicianOffers = []; _customerInspections = []; _technicianInspections = []; _serviceQuotes = []; _serviceAreas = []; _governorates = []; _governoratesLoaded = false; _governoratesFuture = null; _activePayment = null; _wallet = null; notifyListeners(); }
  void setCustomerNavIndex(int index) { _customerNavIndex = index; notifyListeners(); }
  void setTechnicianNavIndex(int index) { _technicianNavIndex = index; notifyListeners(); }

  List<ServiceRequestModel> _enrichRequests(List<ServiceRequestModel> requests, {List<AddressModel> addresses = const []}) {
    return requests.map((request) {
      ServiceModel? service;
      for (final item in _services) {
        if (item.id == request.serviceId) { service = item; break; }
      }
      AddressModel? address;
      for (final item in addresses) {
        if (item.id == request.address.id) { address = item; break; }
      }
      return request.copyWith(
        serviceNameAr: service?.nameAr ?? request.serviceNameAr,
        categoryNameAr: service?.categoryNameAr ?? request.categoryNameAr,
        address: address ?? request.address,
      );
    }).toList();
  }

  Future<void> _refreshAvailableTechnicianRequests({bool notify = true}) async {
    if (!isTechnician) return;
    _isLoadingAvailableTechRequests = true;
    _availableTechRequestsError = null;
    if (notify) notifyListeners();
    try {
      final requests = await _requestRepo.getAvailableRequestsForTechnicians();
      _availableTechRequests = _enrichRequests(requests);
      _availableTechRequestsError = null;
    } catch (e) {
      _availableTechRequests = [];
      _availableTechRequestsError = e.toString();
    } finally {
      _isLoadingAvailableTechRequests = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> refreshAvailableTechnicianRequests() => _refreshAvailableTechnicianRequests();

  void _appendInitializationError(List<String> errors, Object error) {
    final message = error.toString().trim();
    if (message.isEmpty || errors.contains(message)) return;
    errors.add(message);
  }

  Future<void> _initializeCustomerState(List<String> errors) async {
    try { _savedAddresses = await _userRepo.getUserAddresses(_currentUser!.id); } catch (e) { _appendInitializationError(errors, e); }
    try { final requests = await _requestRepo.getRequestsByCustomer(_currentUser!.id); _customerRequests = _enrichRequests(requests, addresses: _savedAddresses); } catch (e) { _appendInitializationError(errors, e); }
    try { _bookings = await _bookingRepo.getBookingsByCustomer(_currentUser!.id); } catch (e) { _appendInitializationError(errors, e); }
  }

  Future<void> _initializeTechnicianState(List<String> errors) async {
    try { await _refreshAvailableTechnicianRequests(notify: false); } catch (e) { _appendInitializationError(errors, e); }
    try { _technicianOffers = await _offerRepo.getMyOffers(); } catch (e) { _appendInitializationError(errors, e); }

    TechnicianProfileModel? profile;
    try {
      final userId = _currentUser!.id;
      profile = await _techRepo.getTechnicianByUserId(userId);
      if (profile == null || profile.id.isEmpty) throw Exception('تعذر العثور على ملف الفني المرتبط بالحساب.');
      debugPrint('[TECH_PROFILE_RESOLUTION]');
      debugPrint('userId: $userId');
      debugPrint('technicianProfileId: ${profile.id}');
      debugPrint('profile.userId: ${profile.userId}');
      if (profile.userId != userId) throw Exception('عدم تطابق هوية ملف الفني مع حساب المستخدم.');
      final technicianProfileId = int.tryParse(profile.id);
      if (technicianProfileId == null || technicianProfileId <= 0) throw Exception('معرف ملف الفني غير صالح.');
      _currentTechProfile = profile;
    } catch (e) { _appendInitializationError(errors, e); return; }

    final technicianProfileId = int.parse(profile.id);
    try { _bookings = await _bookingRepo.getBookingsByTechnician(profile.id); } catch (e) { _appendInitializationError(errors, e); }
    try { _wallet = await _walletRepo.getWalletByTechnician(profile.id); } catch (e) { _appendInitializationError(errors, e); }
    try { _serviceAreas = await _techRepo.getServiceAreas(technicianProfileId); } catch (e) { _appendInitializationError(errors, e); }
  }

  Future<void> _initializeSharedUserState(List<String> errors) async {
    try { _conversations = await _chatRepo.getConversations(_currentUser!.id); } catch (e) { _appendInitializationError(errors, e); }
    try { _notifications = await _userRepo.getUserNotifications(_currentUser!.id); } catch (e) { _appendInitializationError(errors, e); }
  }

  Future<void> _loadInitialData() async {
    final initializationErrors = <String>[];
    try {
      final publicDataFuture = _publicDataFuture;
      if (publicDataFuture != null) { try { await publicDataFuture; } catch (e) { _appendInitializationError(initializationErrors, e); } }
      if (!_publicDataLoadSucceeded) { try { _publicDataFuture = _loadPublicData(); await _publicDataFuture!; } catch (e) { _appendInitializationError(initializationErrors, e); } }
      if (_apiError != null && _apiError!.trim().isNotEmpty && !_publicDataLoadSucceeded) _appendInitializationError(initializationErrors, _apiError!);
      if (_currentUser != null) {
        if (isCustomer) await _initializeCustomerState(initializationErrors); else if (isTechnician) await _initializeTechnicianState(initializationErrors);
        await _initializeSharedUserState(initializationErrors);
      }
    } catch (e) { _appendInitializationError(initializationErrors, e); }
    if (initializationErrors.isNotEmpty) _apiError = initializationErrors.join('\n');
    notifyListeners();
  }

  Future<List<GovernorateDto>> loadGovernoratesForTechnician() async {
    if (_governoratesLoaded) return _governorates;
    final inFlight = _governoratesFuture;
    if (inFlight != null) return inFlight;
    final future = _fetchGovernoratesForTechnician();
    _governoratesFuture = future;
    try { final result = await future; _governorates = result; _governoratesLoaded = true; return result; }
    finally { if (identical(_governoratesFuture, future)) _governoratesFuture = null; }
  }

  Future<List<GovernorateDto>> _fetchGovernoratesForTechnician() async { final client = ApiClient(); final response = await client.get(ApiConstants.governorates); if (response is List) return response.map((e) => GovernorateDto.fromJson(e as Map<String, dynamic>)).toList(); return []; }
  Future<List<CityDto>> loadCitiesForTechnician(int governorateId) async { final client = ApiClient(); final response = await client.get(ApiConstants.citiesByGovernorate(goorvernorateId)); if (response is List) return response.map((e) => CityDto.fromJson(e as Map<String, dynamic>)).toList(); return []; }
  Future<String?> getCityName(int cityId) async { final client = ApiClient(); try { final response = await client.get(ApiConstants.cityById(cityId)); final name = CityDto.fromJson(response as Map<String, dynamic>).name; return name?.trim().isEmpty == true ? null : name; } on ApiException catch (error) { if (error.statusCode == 404) return null; rethrow; } }
  Future<void> selectCategory(String categoryId) async { _selectedCategoryId = categoryId; _categoryError = null; _isLoadingCategoryServices = true; notifyListeners(); try { if (categoryId == 'all') _services = await _serviceRepo.getServices(); else { final categoryName = _categories.firstWhere((c) => c.id == categoryId, orElse: () => _categories.first).nameAr; _services = await _serviceRepo.getServicesByCategory(categoryId, categoryNameAr: categoryName); } } catch (e) { _services = []; _categoryError = e.toString(); } finally { _isLoadingCategoryServices = false; notifyListeners(); } }
  void setSearchQuery(String query) async { _searchQuery = query; _apiError = null; try { _services = await _serviceRepo.searchServices(query); } catch (e) { _apiError = e.toString(); } finally { notifyListeners(); } }
  Future<void> applyPromoCode(String code) async { try { final dto = await _promoRepo.getPromoCodeByCode(code); if (dto != null && dto.isActive) _appliedPromo = PromoCodeModel(code: dto.code ?? code, title: dto.code ?? 'كود خصم', discount: '${dto.discountValue.toStringAsFixed(0)}%', maxDiscount: 'خصم ${dto.discountValue}', description: 'كود ترويجي', expiry: dto.endDate, discountPercentage: dto.discountValue, maxDiscountAmount: dto.discountValue); else _appliedPromo = null; } catch (_) { _appliedPromo = null; } notifyListeners(); }
  void removePromoCode() { _appliedPromo = null; notifyListeners(); }

  Future<ServiceRequestModel> createServiceRequest({required ServiceModel service, required AddressModel address, required String problemDescription, required String preferredDate, required String preferredTime, List<ServiceRequestFileModel>? files}) async {
    if (_currentUser == null) throw Exception('User not authenticated');
    final pricing = service.pricing;
    if (pricing.visitFee == null || pricing.minPrice == null) throw Exception('لم يتم تحديد تسعير الخدمة لهذا العنوان. يرجى اختيار عنوان صالح والمحاولة مرة أخرى.');
    final requestToCreate = ServiceRequestModel(id: 'req-${DateTime.now().millisecondsSinceEpoch}', serviceId: service.id, serviceNameAr: service.nameAr, categoryNameAr: service.categoryNameAr, customerId: _currentUser!.id, customerName: _currentUser!.fullName, customerPhone: _currentUser!.phoneNumber, address: address, problemDescription: problemDescription, preferredDate: preferredDate, preferredTime: preferredTime, files: files ?? [], status: ServiceRequestStatus.pending, visitFee: pricing.visitFee, estimatedPriceMin: pricing.minPrice!, estimatedPriceMax: pricing.maxPrice, createdAt: 'الآن', statusHistory: [ServiceRequestStatusHistoryModel(status: ServiceRequestStatus.pending, timestamp: 'الآن', updatedBy: _currentUser!.fullName)]);
    final newReq = await _requestRepo.createRequest(requestToCreate);
    _customerOffers = [];
    _customerRequests.insert(0, newReq);
    notifyListeners();
    return newReq;
  }

  Future<void> cancelRequest(String requestId, String reason) async { await _requestRepo.cancelRequest(requestId, reason); if (_currentUser != null && isCustomer) _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses); if (isTechnician) await _refreshAvailableTechnicianRequests(); notifyListeners(); }
  Future<void> submitTechnicianOffer({required ServiceRequestModel request, required double proposedPrice, String? technicianNote}) async { final requestId = int.tryParse(request.id); if (requestId == null || requestId <= 0) throw Exception('معرف الطلب غير صالح'); final offer = await _offerRepo.createOffer(serviceRequestId: requestId, proposedPrice: proposedPrice, technicianNote: technicianNote); _technicianOffers.insert(0, offer); _availableTechRequests.removeWhere((r) => r.id == request.id); notifyListeners(); }
  Future<void> loadOffersForCustomerRequest(String requestId) async { final id = int.tryParse(requestId); if (id == null || id <= 0) { _customerOffers = []; notifyListeners(); return; } _customerOffers = await _offerRepo.getOffersForRequest(id); notifyListeners(); }

  Future<void> acceptCustomerOffer(String offerId, String requestId) async {
    final id = int.tryParse(offerId);
    if (id == null || id <= 0) throw Exception('معرف العرض غير صالح');
    final requestIdValue = int.tryParse(requestId);
    if (requestIdValue == null || requestIdValue <= 0) throw Exception('معرف الطلب غير صالح');
    await _offerRepo.acceptOffer(id);
    if (_currentUser != null && isCustomer) {
      _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses);
      final booking = await _bookingRepo.getBookingByRequest(requestId);
      if (booking != null) _upsertBooking(booking);
    }
    _customerOffers = await _offerRepo.getOffersForRequest(requestIdValue);
    notifyListeners();
  }

  Future<void> rejectCustomerOffer(String offerId, String requestId) async { final id = int.tryParse(offerId); if (id == null || id <= 0) throw Exception('معرف العرض غير صالح'); await _offerRepo.rejectOffer(id); _customerOffers = await _offerRepo.getOffersForRequest(int.tryParse(requestId) ?? 0); notifyListeners(); }

  Future<void> updateTechnicianSpecialization({required int categoryId, required List<int> serviceIds}) async { final profile = _currentTechProfile; if (profile == null) throw Exception('تعذر تحديد ملف الفني'); final technicianId = int.tryParse(profile.id); if (technicianId == null || technicianId <= 0) throw Exception('معرف ملف الفني غير صالح'); final updatedProfile = await _techRepo.updateTechnicianSpecialization(technicianId, categoryId: categoryId, serviceIds: serviceIds); _currentTechProfile = updatedProfile; await _refreshAvailableTechnicianRequests(); notifyListeners(); }
  Future<void> loadServiceAreas() async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId > 0) { _serviceAreas = await _techRepo.getServiceAreas(techId); notifyListeners(); } }
  Future<void> addTechnicianServiceArea(int cityId) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); await _techRepo.addServiceArea(techId, cityId); await loadServiceAreas(); await _refreshAvailableTechnicianRequests(); }
  Future<void> removeTechnicianServiceArea(int cityId) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); await _techRepo.deleteServiceArea(techId, cityId); await loadServiceAreas(); await _refreshAvailableTechnicianRequests(); }
  Future<void> updateTechnicianCurrentLocation(double latitude, double longitude) async { final techId = int.tryParse(_currentTechProfile?.id ?? '0') ?? 0; if (techId <= 0) throw Exception('تعذر تحديد ملف الفني'); final dto = await _techRepo.updateApiTechnicianProfile(techId, UpdateTechnicianProfileRequest(currentLatitude: latitude, currentLongitude: longitude)); _currentTechProfile = _currentTechProfile?.copyWith(currentLatitude: dto.currentLatitude, currentLongitude: dto.currentLongitude); notifyListeners(); }

  void _upsertBooking(BookingModel booking) { final index = _bookings.indexWhere((item) => item.id == booking.id); if (index == -1) _bookings.add(booking); else _bookings[index] = booking; }
  Future<BookingModel?> loadBookingForRequest(String requestId) async { final booking = await _bookingRepo.getBookingByRequest(requestId); if (booking != null) { _upsertBooking(booking); notifyListeners(); } return booking; }
  Future<BookingVerificationIssueResult> requestJobStartCode(String bookingId) async => _bookingRepo.issueBookingVerificationCode(bookingId, 'JobStart');
  Future<BookingModel> verifyJobStart(String bookingId, String code) async { final verified = await _bookingRepo.verifyBookingCode(bookingId, 'JobStart', code); final refreshed = await _bookingRepo.getBookingById(bookingId) ?? verified; _upsertBooking(refreshed); notifyListeners(); return refreshed; }
  Future<BookingVerificationIssueResult> requestJobCompletionCode(String bookingId) async => _bookingRepo.issueBookingVerificationCode(bookingId, 'JobCompletion');
  Future<BookingModel> verifyJobCompletion(String bookingId, String code) async { final verified = await _bookingRepo.verifyBookingCode(bookingId, 'JobCompletion', code); final refreshed = await _bookingRepo.getBookingById(bookingId) ?? verified; _upsertBooking(refreshed); if (_currentUser != null && isCustomer) { _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses); } notifyListeners(); return refreshed; }
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async { await _bookingRepo.updateBookingStatus(bookingId, status); if (_currentTechProfile != null) _bookings = await _bookingRepo.getBookingsByTechnician(_currentTechProfile!.id); notifyListeners(); }
  Future<void> toggleTechnicianAvailability() async { if (_currentTechProfile == null) return; final newStatus = !_currentTechProfile!.isAvailable; await _techRepo.updateAvailability(_currentTechProfile!.id, newStatus); _currentTechProfile = _currentTechProfile!.copyWith(isAvailable: newStatus); await _refreshAvailableTechnicianRequests(); notifyListeners(); }
  Future<MessageModel> sendMessage(String conversationId, String text, {String? attachmentUrl}) async { if (_currentUser == null) throw Exception('Not logged in'); final msg = await _chatRepo.sendMessage(conversationId: conversationId, sender: _currentUser!, text: text, attachmentUrl: attachmentUrl); _conversations = await _chatRepo.getConversations(_currentUser!.id); notifyListeners(); return msg; }
  Future<ConversationModel> startConversationWithTechnician({required TechnicianProfileModel technician, String? serviceNameAr, String? requestId}) async { if (_currentUser == null) throw Exception('Not logged in'); final conv = await _chatRepo.getOrCreateConversation(customerId: _currentUser!.id, customerName: _currentUser!.fullName, customerAvatar: _currentUser!.avatarUrl, technicianId: technician.userId, technicianName: technician.fullName, technicianAvatar: technician.avatarUrl, serviceNameAr: serviceNameAr, requestId: requestId); _conversations = await _chatRepo.getConversations(_currentUser!.id); notifyListeners(); return conv; }
  Future<void> addAddress(AddressModel address) async { await _userRepo.addAddress(address); _savedAddresses = await _userRepo.getUserAddresses(_currentUser?.id ?? address.userId); notifyListeners(); }
  Future<void> requestWithdrawal(double amount, String iban) async { if (_currentTechProfile == null) throw Exception('تعذر تحديد ملف الفني'); await _walletRepo.requestWithdrawal(_currentTechProfile!.id, amount, iban); _wallet = await _walletRepo.getWalletByTechnician(_currentTechProfile!.id); notifyListeners(); }
  void markNotificationAsRead(String id) { _userRepo.markNotificationAsRead(id); final index = _notifications.indexWhere((n) => n.id == id); if (index != -1) { _notifications[index] = _notifications[index].copyWith(isRead: true); notifyListeners(); } }
  Future<void> markAllNotificationsAsRead() async { for (var i = 0; i < _notifications.length; i++) { if (!_notifications[i].isRead) { _notifications[i] = _notifications[i].copyWith(isRead: true); _userRepo.markNotificationAsRead(_notifications[i].id); } } notifyListeners(); }
  Future<void> submitReview({required String requestId, required String technicianId, required double rating, String? comment, String? serviceNameAr}) async { if (_currentUser == null) return; await _reviewRepo.createReview(CreateReviewRequest(serviceRequestId: int.tryParse(requestId) ?? 0, customerId: int.tryParse(_currentUser!.id) ?? 0, technicianId: int.tryParse(technicianId) ?? 0, rating: rating.toInt(), comment: comment)); notifyListeners(); }
  Future<void> uploadDocument({required String titleAr, required String titleEn, required String documentType, String? documentNumber, String? fileUrl}) async { final profile = _currentTechProfile; if (profile == null) throw Exception('تعذر تحديد ملف الفني'); final techId = int.tryParse(profile.id); if (techId == null || techId <= 0) throw Exception('معرف ملف الفني غير صالح'); final docDto = await _techRepo.uploadDocument(CreateTechnicianDocumentRequest(technicianId: techId, documentType: documentType, documentUrl: fileUrl ?? 'https://example.com/doc.pdf')); _technicianDocuments.add(TechnicianDocumentModel(id: docDto.id.toString(), technicianId: docDto.technicianId.toString(), titleAr: titleAr, titleEn: titleEn, documentType: docDto.documentType ?? documentType, documentNumber: documentNumber, fileUrl: docDto.documentUrl ?? '', status: DocumentStatus.fromString(docDto.status ?? 'Pending'), submittedAt: docDto.uploadedAt.isNotEmpty ? docDto.uploadedAt : 'الآن')); notifyListeners(); }
  Future<List<PaymentModel>> loadPaymentsForRequest(String requestId) async { final reqId = int.tryParse(requestId) ?? 0; if (reqId == 0) return []; try { final dtoList = await _paymentRepo.getPaymentsByRequestId(reqId); final mapped = dtoList.map((d) => PaymentModel.fromDto(d)).toList(); _payments = mapped; notifyListeners(); return mapped; } catch (_) { return []; } }
  Future<InitiatePaymentResponse> initiatePayment({required String serviceRequestId, required PaymentMethodType method, String? walletPhoneNumber, String paymentType = 'FullService'}) async { final reqId = int.tryParse(serviceRequestId) ?? 0; if (reqId == 0) throw Exception('معرف طلب الخدمة غير صالح'); _isLoading = true; _errorMessage = null; notifyListeners(); try { final response = await _paymentRepo.initiatePayment(InitiatePaymentRequest(serviceRequestId: reqId, paymentMethod: method.nameStr, walletPhoneNumber: walletPhoneNumber, paymentType: paymentType)); _activePayment = PaymentModel.fromInitiateResponse(response, serviceRequestId, response.amount); _isLoading = false; notifyListeners(); return response; } catch (e) { _isLoading = false; _errorMessage = e.toString(); notifyListeners(); rethrow; } }
  Future<VerifyPaymentResponse> verifyPayment(int paymentId) async { _isLoading = true; notifyListeners(); try { final verifyResp = await _paymentRepo.verifyPayment(paymentId); if (_activePayment != null && _activePayment!.id == paymentId.toString()) _activePayment = _activePayment!.copyWith(status: PaymentStatusTypeExtension.fromString(verifyResp.status), transactionReference: verifyResp.transactionReference, paidAt: verifyResp.paidAt); if (verifyResp.isSuccess && _currentUser != null) _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses); _isLoading = false; notifyListeners(); return verifyResp; } catch (e) { _isLoading = false; notifyListeners(); rethrow; } }
  Future<PaymentDto> selectCashOnDelivery(String serviceRequestId) async { final reqId = int.tryParse(serviceRequestId) ?? 0; if (reqId == 0) throw Exception('معرف طلب الخدمة غير صالح'); _isLoading = true; _errorMessage = null; notifyListeners(); try { final dto = await _paymentRepo.setCashPayment(reqId); _activePayment = PaymentModel.fromDto(dto); if (_currentUser != null) _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses); _isLoading = false; notifyListeners(); return dto; } catch (e) { _isLoading = false; _errorMessage = e.toString(); notifyListeners(); rethrow; } }

  void _upsertInspection(InspectionModel inspection) { final target = isTechnician ? _technicianInspections : _customerInspections; final index = target.indexWhere((item) => item.id == inspection.id); if (index == -1) target.add(inspection); else target[index] = inspection; }
  void _upsertQuote(ServiceQuoteModel quote) { final index = _serviceQuotes.indexWhere((item) => item.id == quote.id); if (index == -1) _serviceQuotes.add(quote); else _serviceQuotes[index] = quote; }

  Future<void> loadTechnicianInspections() async { if (!isTechnician) return; _technicianInspections = await _inspectionRepo.getMyInspections(); notifyListeners(); }
  Future<void> loadCustomerInspections(Iterable<String> requestIds) async { if (!isCustomer) return; final loaded = <InspectionModel>[]; for (final requestId in requestIds) { final id = int.tryParse(requestId); if (id == null || id <= 0) continue; final inspection = await _inspectionRepo.getInspectionByRequest(id); if (inspection != null) loaded.add(inspection); } _customerInspections = loaded; notifyListeners(); }
  Future<InspectionModel?> loadInspectionForRequest(String requestId) async { final id = int.tryParse(requestId); if (id == null || id <= 0) return null; final inspection = await _inspectionRepo.getInspectionByRequest(id); if (inspection != null) { _upsertInspection(inspection); notifyListeners(); } return inspection; }
  Future<InspectionModel?> loadInspection(String inspectionId) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) return null; final inspection = await _inspectionRepo.getInspection(id); if (inspection != null) { _upsertInspection(inspection); notifyListeners(); } return inspection; }
  Future<InspectionModel> createInspection({required int serviceRequestId, required DateTime scheduledAt}) async { final inspection = await _inspectionRepo.createInspection(serviceRequestId: serviceRequestId, scheduledAt: scheduledAt); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<InspectionModel> scheduleInspection(String inspectionId, DateTime scheduledAt) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف المعاينة غير صالح'); final inspection = await _inspectionRepo.scheduleInspection(id, scheduledAt); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<InspectionModel> startInspection(String inspectionId) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف المعاينة غير صالح'); final inspection = await _inspectionRepo.startInspection(id); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<InspectionModel> completeInspection(String inspectionId, String findings) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف المعاينة غير صالح'); final inspection = await _inspectionRepo.completeInspection(id, findings); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<InspectionModel> cancelInspection(String inspectionId) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف المعاينة غير صالح'); final inspection = await _inspectionRepo.cancelInspection(id); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<InspectionModel> noShowInspection(String inspectionId) async { final id = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف المعاينة غير صالح'); final inspection = await _inspectionRepo.noShowInspection(id); _upsertInspection(inspection); notifyListeners(); return inspection; }
  Future<List<ServiceQuoteModel>> loadServiceQuotes(int inspectionId) async { _serviceQuotes = await _serviceQuoteRepo.getQuotesByInspection(inspectionId); notifyListeners(); return _serviceQuotes; }
  Future<ServiceQuoteModel> createServiceQuote({required int inspectionId, required double amount, String? notes, DateTime? expiresAt}) async { final quote = await _serviceQuoteRepo.createQuote(inspectionId: inspectionId, amount: amount, notes: notes, expiresAt: expiresAt); _upsertQuote(quote); notifyListeners(); return quote; }
  Future<ServiceQuoteModel> createQuoteRevision({required int quoteId, required double amount, String? notes, DateTime? expiresAt}) async { final quote = await _serviceQuoteRepo.createRevision(quoteId: quoteId, amount: amount, notes: notes, expiresAt: expiresAt); _upsertQuote(quote); notifyListeners(); return quote; }
  Future<void> acceptServiceQuote(String quoteId, String inspectionId) async { final id = int.tryParse(quoteId); final inspectionValue = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف عرض السعر غير صالح'); if (inspectionValue == null || inspectionValue <= 0) throw Exception('معرف المعاينة غير صالح'); await _serviceQuoteRepo.acceptQuote(id); _serviceQuotes = await _serviceQuoteRepo.getQuotesByInspection(inspectionValue); if (_currentUser != null && isCustomer) { _bookings = await _bookingRepo.getBookingsByCustomer(_currentUser!.id); _customerRequests = _enrichRequests(await _requestRepo.getRequestsByCustomer(_currentUser!.id), addresses: _savedAddresses); } notifyListeners(); }
  Future<void> rejectServiceQuote(String quoteId, String inspectionId) async { final id = int.tryParse(quoteId); final inspectionValue = int.tryParse(inspectionId); if (id == null || id <= 0) throw Exception('معرف عرض السعر غير صالح'); if (inspectionValue == null || inspectionValue <= 0) throw Exception('معرف المعاينة غير صالح'); await _serviceQuoteRepo.rejectQuote(id); _serviceQuotes = await _serviceQuoteRepo.getQuotesByInspection(inspectionValue); notifyListeners(); }
}
