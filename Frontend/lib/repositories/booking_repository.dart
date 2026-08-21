import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/booking_contract_dto.dart';
import '../models/booking_model.dart';
import '../models/address_model.dart';

class BookingVerificationIssueResult {
  final String message;
  final String? developmentCode;

  const BookingVerificationIssueResult({required this.message, this.developmentCode});

  factory BookingVerificationIssueResult.fromJson(Map<String, dynamic> json) {
    return BookingVerificationIssueResult(
      message: json['message']?.toString() ?? 'تم إرسال رمز التحقق.',
      developmentCode: json['developmentCode']?.toString(),
    );
  }
}

abstract class IBookingRepository {
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId);
  Future<List<BookingModel>> getBookingsByCustomer(String customerId);
  Future<BookingModel?> getBookingById(String id);
  Future<BookingModel?> getBookingByRequest(String requestId);
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingVerificationIssueResult> issueBookingVerificationCode(String bookingId, String purpose);
  Future<BookingModel> verifyBookingCode(String bookingId, String purpose, String code);

  Future<BookingDto> getApiBookingById(int id);
  Future<BookingDto> getApiBookingByRequest(int serviceRequestId);
  Future<List<BookingDto>> getApiBookingsByTechnician(int technicianId);
  Future<BookingDto> createApiBooking(CreateBookingRequest request);
  Future<BookingDto> updateApiBooking(int id, UpdateBookingRequest request);
}

class BookingRepository implements IBookingRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId) async {
    final intId = int.tryParse(technicianId);
    if (intId == null || intId <= 0) return [];
    try {
      final response = await _client.get(ApiConstants.bookingsByTechnician(intId));
      if (response is List) {
        return response.whereType<Map<String, dynamic>>().map(_mapRawJsonToModel).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByCustomer(String customerId) async {
    final intId = int.tryParse(customerId);
    if (intId == null) return [];
    try {
      final reqResponse = await _client.get(ApiConstants.serviceRequestsByCustomer(intId));
      if (reqResponse is List) {
        final List<BookingModel> customerBookings = [];
        for (final reqJson in reqResponse.whereType<Map<String, dynamic>>()) {
          final requestId = reqJson['id'] is int
              ? reqJson['id'] as int
              : int.tryParse(reqJson['id']?.toString() ?? '0') ?? 0;
          if (requestId <= 0) continue;
          try {
            final response = await _client.get(ApiConstants.bookingByRequest(requestId));
            if (response is Map<String, dynamic>) {
              customerBookings.add(_mapRawJsonToModel(response));
            }
          } catch (_) {}
        }
        return customerBookings;
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null || intId <= 0) return null;
    final response = await _client.get(ApiConstants.bookingById(intId));
    if (response is! Map<String, dynamic>) throw Exception('استجابة الحجز غير صالحة');
    return _mapRawJsonToModel(response);
  }

  @override
  Future<BookingModel?> getBookingByRequest(String requestId) async {
    final intId = int.tryParse(requestId);
    if (intId == null || intId <= 0) return null;
    try {
      final response = await _client.get(ApiConstants.bookingByRequest(intId));
      if (response is! Map<String, dynamic>) throw Exception('استجابة الحجز غير صالحة');
      return _mapRawJsonToModel(response);
    } catch (e) {
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final intId = int.tryParse(bookingId);
    if (intId == null || intId <= 0) throw Exception('معرف الحجز غير صالح');
    final response = await _client.post(
      ApiConstants.bookingTransition(intId),
      body: {'status': newStatus.nameStr},
    );
    if (response is! Map<String, dynamic>) throw Exception('استجابة انتقال حالة الحجز غير صالحة');
    return _mapRawJsonToModel(response);
  }

  @override
  Future<BookingVerificationIssueResult> issueBookingVerificationCode(String bookingId, String purpose) async {
    final id = int.tryParse(bookingId);
    if (id == null || id <= 0) throw Exception('معرف الحجز غير صالح');
    if (purpose != 'JobStart' && purpose != 'JobCompletion') throw Exception('غرض التحقق غير صالح');
    final response = await _client.post(ApiConstants.bookingVerificationCode(id, purpose));
    if (response is! Map<String, dynamic>) throw Exception('استجابة طلب رمز التحقق غير صالحة');
    return BookingVerificationIssueResult.fromJson(response);
  }

  @override
  Future<BookingModel> verifyBookingCode(String bookingId, String purpose, String code) async {
    final id = int.tryParse(bookingId);
    if (id == null || id <= 0) throw Exception('معرف الحجز غير صالح');
    if (purpose != 'JobStart' && purpose != 'JobCompletion') throw Exception('غرض التحقق غير صالح');
    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedCode)) {
      throw Exception('يجب إدخال رمز تحقق مكون من 6 أرقام.');
    }
    final response = await _client.post(
      ApiConstants.bookingVerifyCode(id, purpose),
      body: normalizedCode,
    );
    if (response is! Map<String, dynamic>) throw Exception('استجابة التحقق غير صالحة');
    return _mapRawJsonToModel(response);
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final requestId = int.tryParse(booking.requestId);
    final technicianId = int.tryParse(booking.technicianId);
    if (requestId == null || technicianId == null) throw Exception('بيانات الحجز غير صالحة');
    final dto = await createApiBooking(CreateBookingRequest(serviceRequestId: requestId, technicianId: technicianId));
    return _mapDtoToModel(dto, fallback: booking);
  }

  BookingModel _mapRawJsonToModel(Map<String, dynamic> json, {BookingModel? fallback}) {
    final contract = BookingContractDto.fromJson(json);
    return BookingModel(
      id: contract.id.toString(),
      requestId: contract.serviceRequestId.toString(),
      serviceNameAr: fallback?.serviceNameAr ?? '',
      customerName: fallback?.customerName ?? '',
      customerPhone: fallback?.customerPhone ?? '',
      technicianId: contract.technicianId.toString(),
      technicianName: fallback?.technicianName ?? '',
      address: fallback?.address ?? AddressModel(
        id: '',
        userId: '',
        title: 'العنوان',
        governorate: '',
        city: '',
        street: '',
        building: '',
        floor: '',
        apartment: '',
      ),
      scheduledDate: contract.acceptedAt ?? fallback?.scheduledDate ?? '',
      scheduledTime: fallback?.scheduledTime ?? '',
      price: contract.finalPrice ?? contract.agreedPrice ?? fallback?.price ?? 0.0,
      status: BookingStatus.fromString(contract.status),
      createdAt: contract.acceptedAt ?? fallback?.createdAt ?? '',
      acceptedAt: contract.acceptedAt,
      arrivedAt: contract.arrivedAt,
      startedAt: contract.startedAt,
      completedAt: contract.completedAt,
      agreedPrice: contract.agreedPrice,
      finalPrice: contract.finalPrice,
      notes: contract.technicianNotes ?? fallback?.notes,
    );
  }

  BookingModel _mapDtoToModel(BookingDto dto, {BookingModel? fallback}) {
    final legacyStatus = dto.completedAt != null
        ? BookingStatus.completed
        : dto.startedAt != null
            ? BookingStatus.inProgress
            : dto.arrivedAt != null
                ? BookingStatus.arrived
                : BookingStatus.upcoming;
    return BookingModel(
      id: dto.id.toString(),
      requestId: dto.serviceRequestId.toString(),
      serviceNameAr: fallback?.serviceNameAr ?? '',
      customerName: fallback?.customerName ?? '',
      customerPhone: fallback?.customerPhone ?? '',
      technicianId: dto.technicianId.toString(),
      technicianName: fallback?.technicianName ?? '',
      address: fallback?.address ?? AddressModel(
        id: '', userId: '', title: 'العنوان', governorate: '', city: '', street: '', building: '', floor: '', apartment: '',
      ),
      scheduledDate: dto.acceptedAt ?? fallback?.scheduledDate ?? '',
      scheduledTime: fallback?.scheduledTime ?? '',
      price: dto.finalPrice ?? fallback?.price ?? 0.0,
      status: legacyStatus,
      createdAt: dto.acceptedAt ?? fallback?.createdAt ?? '',
      acceptedAt: dto.acceptedAt,
      arrivedAt: dto.arrivedAt,
      startedAt: dto.startedAt,
      completedAt: dto.completedAt,
      agreedPrice: fallback?.agreedPrice,
      finalPrice: dto.finalPrice,
      notes: dto.technicianNotes,
    );
  }

  @override
  Future<BookingDto> getApiBookingById(int id) async {
    final response = await _client.get(ApiConstants.bookingById(id));
    return BookingDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookingDto> getApiBookingByRequest(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.bookingByRequest(serviceRequestId));
    return BookingDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<BookingDto>> getApiBookingsByTechnician(int technicianId) async {
    final response = await _client.get(ApiConstants.bookingsByTechnician(technicianId));
    if (response is List) return response.map((item) => BookingDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<BookingDto> createApiBooking(CreateBookingRequest request) async {
    final response = await _client.post(ApiConstants.bookings, body: request.toJson());
    return BookingDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookingDto> updateApiBooking(int id, UpdateBookingRequest request) async {
    final response = await _client.put(ApiConstants.bookingById(id), body: request.toJson());
    return BookingDto.fromJson(response as Map<String, dynamic>);
  }
}
