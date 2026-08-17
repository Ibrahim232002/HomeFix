import 'package:flutter/material.dart';

import '../auth/auth_session_provider.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
import '../models/service_request_model.dart';
import '../models/booking_model.dart';
import '../models/technician_profile_model.dart';
import '../models/technician_document_model.dart';
import '../models/wallet_model.dart';
import '../models/chat_model.dart';
import '../models/notification_model.dart';
import '../models/address_model.dart';
import '../models/review_model.dart';
import '../models/promo_code_model.dart';
import '../models/payment_model.dart';
import '../models/service_request_offer_model.dart';

import '../repositories/service_repository.dart';
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

/// Domain/application state. Authentication/session ownership lives exclusively
/// in AuthSessionProvider.
class AppStateProvider extends ChangeNotifier {
  AppStateProvider({required AuthSessionProvider session}) : _session = session;

  AuthSessionProvider _session;

  void bindSession(AuthSessionProvider session) {
    if (identical(_session, session)) return;
    _session = session;
  }

  final IServiceRepository _serviceRepo = ServiceRepository();
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

  bool _isLoading = false;
  bool _isLoadingPublic = false;
  bool _publicDataLoaded = false;
  Future<void>? _publicDataLoad;
  String? _errorMessage;
  String? _apiError;

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
  List<ServiceRequestOfferModel> _offers = [];
  PaymentModel? _activePayment;
  WalletModel? _wallet;

  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  PromoCodeModel? _appliedPromo;
  TechnicianProfileModel? _currentTechProfile;
  bool _disposed = false;

  UserModel? get currentUser => _session.user;
  bool get isAuthenticated => _session.isAuthenticated;
  UserRole get currentRole => _session.role;
  bool get isCustomer => _session.role == UserRole.customer;
  bool get isTechnician => _session.role == UserRole.technician;
  bool get isLoading => _isLoading;
  bool get isLoadingPublic => _isLoadingPublic;
  String? get errorMessage => _errorMessage ?? _session.errorMessage;
  String? get apiError => _apiError;
  AuthSessionStatus get authStatus => _session.status;

  int get customerNavIndex => _customerNavIndex;
  int get technicianNavIndex => _technicianNavIndex;
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ServiceModel> get services => List.unmodifiable(_services);
  List<ServiceRequestModel> get customerRequests => List.unmodifiable(_customerRequests);
  List<ServiceRequestModel> get availableTechRequests => List.unmodifiable(_availableTechRequests);
  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<TechnicianProfileModel> get technicians => List.unmodifiable(_technicians);
  List<ConversationModel> get conversations => List.unmodifiable(_conversations);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<AddressModel> get savedAddresses => List.unmodifiable(_savedAddresses);
  List<TechnicianDocumentModel> get technicianDocuments => List.unmodifiable(_technicianDocuments);
  List<PaymentModel> get payments => List.unmodifiable(_payments);
  List<ServiceRequestOfferModel> get offers => List.unmodifiable(_offers);
  PaymentModel? get activePayment => _activePayment;
  WalletModel? get wallet => _wallet;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  PromoCodeModel? get appliedPromo => _appliedPromo;
  TechnicianProfileModel? get currentTechProfile => _currentTechProfile;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _loadPublicData() {
    final inFlight = _publicDataLoad;
    if (inFlight != null) return inFlight;

    final future = _performPublicDataLoad();
    _publicDataLoad = future.whenComplete(() => _publicDataLoad = null);
    return _publicDataLoad!;
  }

  Future<void> _performPublicDataLoad() async {
    _isLoadingPublic = true;
    _apiError = null;
    _notify();
    try {
      _services = await _serviceRepo.getServices();
      _technicians = await _techRepo.getTechnicians();
      final catMap = <String, String>{};
      for (final service in _services) {
        if (service.categoryId.isNotEmpty) {
          catMap.putIfAbsent(service.categoryId, () => service.categoryNameAr);
        }
      }
      _categories = catMap.entries
          .map((entry) => CategoryModel(id: entry.key, nameAr: entry.value, nameEn: entry.value, iconName: 'Wrench', colorHex: '#0284c7', image: '', descriptionAr: entry.value))
          .toList();
      _publicDataLoaded = true;
    } catch (e) {
      _publicDataLoaded = false;
      _apiError = e.toString();
    } finally {
      _isLoadingPublic = false;
      _notify();
    }
  }

  Future<void> refreshPublicData() => _loadPublicData();

  Future<void> login(String email, String password, UserRole role) async {
    final success = await _session.login(email, password);
    if (success) await refreshAuthenticatedData();
    _notify();
  }

  Future<void> register({required String fullName, required String email, required String phoneNumber, required String password, required UserRole role}) async {
    await _session.register(fullName: fullName, email: email, phoneNumber: phoneNumber, password: password, role: role);
    _notify();
  }

  Future<void> loginWithPhone(String phone, String otp, UserRole role) async {
    throw UnsupportedError('Phone/SMS OTP login is not exposed by the current backend contract.');
  }

  Future<void> logout() async {
    await _session.logout();
    _clearAuthenticatedData();
    _notify();
  }

  Future<void> refreshAuthenticatedData() async {
    final user = currentUser;
    if (user == null) {
      _clearAuthenticatedData();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    _notify();
    try {
      if (!_publicDataLoaded) {
        await _loadPublicData();
      }
      _conversations = await _chatRepo.getConversations(user.id);
      _notifications = await _userRepo.getUserNotifications(user.id);
      if (isCustomer) {
        _customerRequests = await _requestRepo.getRequestsByCustomer(user.id);
        _savedAddresses = await _userRepo.getUserAddresses(user.id);
        _offers = [];
      } else {
        _availableTechRequests = await _requestRepo.getAvailableRequestsForTechnicians();
        _currentTechProfile = await _techRepo.getTechnicianById(user.id);
        final techId = _currentTechProfile?.id.toString() ?? user.id;
        _bookings = await _bookingRepo.getBookingsByTechnician(techId);
        _wallet = await _walletRepo.getWalletByTechnician(techId);
        _offers = await _offerRepo.getMine();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void setCustomerNavIndex(int index) { _customerNavIndex = index; _notify(); }
  void setTechnicianNavIndex(int index) { _technicianNavIndex = index; _notify(); }

  Future<void> selectCategory(String categoryId) async {
    _selectedCategoryId = categoryId;
    _services = categoryId == 'all' ? await _serviceRepo.getServices() : await _serviceRepo.getServicesByCategory(categoryId);
    _notify();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _services = await _serviceRepo.searchServices(query);
    _notify();
  }

  Future<void> applyPromoCode(String code) async {
    _errorMessage = 'كوبونات الخصم غير متاحة لتطبيقها على طلب الخدمة في عقد الـAPI الحالي.';
    _appliedPromo = null;
    _notify();
  }

  void removePromoCode() { _appliedPromo = null; _notify(); }

  Future<ServiceRequestModel> createServiceRequest({required ServiceModel service, required AddressModel address, required String problemDescription, required String preferredDate, required String preferredTime, List<ServiceRequestFileModel>? files}) async {
    if (currentUser == null) throw StateError('User not authenticated');
    if (files?.isNotEmpty == true) {
      throw UnsupportedError('Service-request file upload is not available in the current backend contract. The API accepts file URLs only and exposes no binary upload endpoint.');
    }
    final request = ServiceRequestModel(
      id: '', serviceId: service.id, serviceNameAr: service.nameAr, categoryNameAr: service.categoryNameAr,
      customerId: currentUser!.id, customerName: currentUser!.fullName, customerPhone: currentUser!.phoneNumber,
      address: address, problemDescription: problemDescription.trim(), preferredDate: preferredDate, preferredTime: preferredTime,
      files: const [], status: ServiceRequestStatus.pending, estimatedPriceMin: 0, estimatedPriceMax: 0, createdAt: '', statusHistory: const [],
    );
    final created = await _requestRepo.createRequest(request);
    _customerRequests = [created, ..._customerRequests.where((r) => r.id != created.id)];
    _notify();
    return created;
  }

  Future<void> cancelRequest(String requestId, String reason) async => throw UnsupportedError('Request cancellation is not exposed by the current backend contract.');

  Future<ServiceRequestOfferModel> createOffer(ServiceRequestModel request, {required double proposedPrice, String? technicianNote}) async {
    final requestId = int.tryParse(request.id);
    if (requestId == null) throw ArgumentError('معرف الطلب غير صالح');
    final offer = await _offerRepo.create(serviceRequestId: requestId, proposedPrice: proposedPrice, technicianNote: technicianNote);
    _offers = [offer, ..._offers.where((item) => item.id != offer.id)];
    _notify();
    return offer;
  }

  Future<List<ServiceRequestOfferModel>> loadOffersForRequest(String requestId) async {
    final parsedId = int.tryParse(requestId);
    if (parsedId == null) return [];
    final result = await _offerRepo.getByRequest(parsedId);
    _offers = result;
    _notify();
    return result;
  }

  Future<void> acceptOffer(String offerId) async { await _offerRepo.accept(int.parse(offerId)); if (currentUser != null) await refreshAuthenticatedData(); }
  Future<void> rejectOffer(String offerId) async { await _offerRepo.reject(int.parse(offerId)); _notify(); }
  Future<void> acceptRequest(ServiceRequestModel request) async => throw UnsupportedError('Technicians must create an offer; booking creation is performed by offer acceptance.');

  Future<void> updateBookingStatus(String bookingId, BookingStatus status, {double? finalPrice, String? notes}) async {
    await _bookingRepo.updateBookingStatus(bookingId, status, finalPrice: finalPrice, notes: notes);
    await refreshAuthenticatedData();
  }

  Future<void> requestVerificationCode(String bookingId, String purpose) => _bookingRepo.requestVerificationCode(bookingId, purpose);

  Future<BookingModel> verifyBookingCode(String bookingId, String purpose, String code) async {
    final booking = await _bookingRepo.verifyBookingCode(bookingId, purpose, code);
    await refreshAuthenticatedData();
    return booking;
  }

  Future<void> toggleTechnicianAvailability() async {
    if (_currentTechProfile == null) return;
    final newStatus = !_currentTechProfile!.isAvailable;
    await _techRepo.updateAvailability(_currentTechProfile!.id, newStatus);
    _currentTechProfile = _currentTechProfile!.copyWith(isAvailable: newStatus);
    _notify();
  }

  Future<MessageModel> sendMessage(String conversationId, String text, {String? attachmentUrl}) async {
    final user = currentUser;
    if (user == null) throw StateError('Not logged in');
    if (text.trim().isEmpty && (attachmentUrl == null || attachmentUrl.trim().isEmpty)) throw ArgumentError('Message cannot be empty');
    final msg = await _chatRepo.sendMessage(conversationId: conversationId, sender: user, text: text.trim(), attachmentUrl: attachmentUrl);
    _conversations = await _chatRepo.getConversations(user.id);
    _notify();
    return msg;
  }

  Future<ConversationModel> startConversationWithTechnician({required TechnicianProfileModel technician, String? serviceNameAr, String? requestId}) async {
    final user = currentUser;
    if (user == null) throw StateError('Not logged in');
    final conv = await _chatRepo.getOrCreateConversation(customerId: user.id, customerName: user.fullName, customerAvatar: user.avatarUrl, technicianId: technician.userId, technicianName: technician.fullName, technicianAvatar: technician.avatarUrl, serviceNameAr: serviceNameAr, requestId: requestId);
    _conversations = await _chatRepo.getConversations(user.id);
    _notify();
    return conv;
  }

  Future<void> addAddress(AddressModel address) async { final added = await _userRepo.addAddress(address); _savedAddresses = [added, ..._savedAddresses.where((item) => item.id != added.id)]; _notify(); }

  Future<void> requestWithdrawal(double amount, String iban) async { final user = currentUser; if (user == null) throw StateError('Not authenticated'); await _walletRepo.requestWithdrawal(user.id, amount, iban); _wallet = await _walletRepo.getWalletByTechnician(user.id); _notify(); }

  Future<void> markNotificationAsRead(String id) async { await _userRepo.markNotificationAsRead(id); final index = _notifications.indexWhere((n) => n.id == id); if (index != -1) { _notifications[index] = _notifications[index].copyWith(isRead: true); _notify(); } }

  Future<void> markAllNotificationsAsRead() async { final unread = _notifications.where((n) => !n.isRead).toList(); for (final notification in unread) { await _userRepo.markNotificationAsRead(notification.id); } _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList(); _notify(); }

  Future<void> submitReview({required String requestId, required String technicianId, required double rating, String? comment, String? serviceNameAr}) async {
    final user = currentUser;
    if (user == null) throw StateError('Not authenticated');
    final reqId = int.tryParse(requestId), techId = int.tryParse(technicianId), custId = int.tryParse(user.id);
    if (reqId == null || techId == null || custId == null) throw ArgumentError('بيانات التقييم غير صالحة');
    await _reviewRepo.createReview(CreateReviewRequest(serviceRequestId: reqId, customerId: custId, technicianId: techId, rating: rating.toInt(), comment: comment?.trim()));
    _notify();
  }

  Future<void> uploadDocument({required String titleAr, required String titleEn, required String documentType, String? documentNumber, String? fileUrl}) async {
    final user = currentUser;
    if (user == null) throw StateError('Not authenticated');
    final techId = int.tryParse(_currentTechProfile?.id ?? user.id);
    if (techId == null) throw ArgumentError('Technician id is invalid');
    if (fileUrl == null || fileUrl.trim().isEmpty) throw ArgumentError('Document upload requires a real file URL.');
    final docDto = await _techRepo.uploadDocument(CreateTechnicianDocumentRequest(technicianId: techId, documentType: documentType, documentUrl: fileUrl.trim()));
    _technicianDocuments = [..._technicianDocuments, TechnicianDocumentModel(id: docDto.id.toString(), technicianId: docDto.technicianId.toString(), titleAr: titleAr, titleEn: titleEn, documentType: docDto.documentType ?? documentType, documentNumber: documentNumber, fileUrl: docDto.documentUrl ?? '', status: DocumentStatus.fromString(docDto.status ?? 'Pending'), submittedAt: docDto.uploadedAt)];
    _notify();
  }

  Future<List<PaymentModel>> loadPaymentsForRequest(String requestId) async { final reqId = int.tryParse(requestId); if (reqId == null) return []; final dtoList = await _paymentRepo.getPaymentsByRequestId(reqId); final mapped = dtoList.map(PaymentModel.fromDto).toList(); _payments = mapped; _notify(); return mapped; }

  Future<PaymentDto> selectCashOnDelivery(String serviceRequestId) async {
    final reqId = int.tryParse(serviceRequestId); if (reqId == null) throw ArgumentError('معرف طلب الخدمة غير صالح');
    _isLoading = true; _errorMessage = null; _notify();
    try { final dto = await _paymentRepo.setCashPayment(reqId); _activePayment = PaymentModel.fromDto(dto); if (currentUser != null) _customerRequests = await _requestRepo.getRequestsByCustomer(currentUser!.id); return dto; }
    finally { _isLoading = false; _notify(); }
  }

  Future<InitiatePaymentResponse> initiatePayment({required String serviceRequestId, required PaymentMethodType method, String? walletPhoneNumber, String paymentType = 'FullService'}) async => throw UnsupportedError('Online gateway payment is not available to customers in the current backend contract.');
  Future<VerifyPaymentResponse> verifyPayment(int paymentId) async => throw UnsupportedError('Online gateway payment verification is not available to customers in the current backend contract.');

  void _clearAuthenticatedData() {
    _customerRequests = []; _availableTechRequests = []; _bookings = []; _conversations = []; _notifications = []; _savedAddresses = []; _technicianDocuments = []; _payments = []; _offers = []; _activePayment = null; _wallet = null; _currentTechProfile = null; _errorMessage = null;
  }

  void _notify() { if (!_disposed) notifyListeners(); }

  @override
  void dispose() { _disposed = true; super.dispose(); }
}
