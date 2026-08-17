import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../models/address_model.dart';

abstract class IBookingRepository {
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId);
  Future<List<BookingModel>> getBookingsByCustomer(String customerId);
  Future<BookingModel?> getBookingById(String id);
  Future<BookingModel?> getBookingByRequest(String requestId);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus, {double? finalPrice, String? notes});
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> requestVerificationCode(String bookingId, String purpose);
  Future<BookingModel> verifyBookingCode(String bookingId, String purpose, String code);
}

class BookingRepository implements IBookingRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId) async {
    final intId = int.tryParse(technicianId);
    if (intId == null) return [];
    final response = await _client.get(ApiConstants.bookingsByTechnician(intId));
    if (response is! List) return [];
    return response.map((item) => _mapBooking(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BookingModel>> getBookingsByCustomer(String customerId) async {
    final intId = int.tryParse(customerId);
    if (intId == null) return [];
    final requests = await _client.get(ApiConstants.serviceRequestsByCustomer(intId));
    if (requests is! List) return [];

    final bookings = <BookingModel>[];
    for (final request in requests) {
      final requestId = (request as Map<String, dynamic>)['id'];
      final parsedRequestId = requestId is int ? requestId : int.tryParse(requestId?.toString() ?? '');
      if (parsedRequestId == null) continue;
      final booking = await getBookingByRequest(parsedRequestId.toString());
      if (booking != null) bookings.add(booking);
    }
    return bookings;
  }

  @override
  Future<BookingModel?> getBookingByRequest(String requestId) async {
    final intId = int.tryParse(requestId);
    if (intId == null) return null;
    try {
      final response = await _client.get(ApiConstants.bookingByRequest(intId));
      if (response is! Map<String, dynamic>) return null;
      return _mapBooking(response);
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final response = await _client.get(ApiConstants.bookingById(intId));
    if (response is! Map<String, dynamic>) return null;
    return _mapBooking(response);
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    double? finalPrice,
    String? notes,
  }) async {
    final intId = int.tryParse(bookingId);
    if (intId == null) throw ArgumentError('معرف الحجز غير صالح');

    await _client.post(
      '${ApiConstants.bookingById(intId)}/transition',
      body: {
        'status': newStatus.nameStr,
        if (finalPrice != null) 'finalPrice': finalPrice,
        if (notes != null && notes.trim().isNotEmpty) 'technicianNotes': notes.trim(),
      },
    );
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    throw UnsupportedError(
      'Booking creation is not available to the client. The current backend creates bookings through offer acceptance.',
    );
  }

  @override
  Future<void> requestVerificationCode(String bookingId, String purpose) async {
    final intId = int.tryParse(bookingId);
    if (intId == null) throw ArgumentError('معرف الحجز غير صالح');
    if (purpose != 'JobStart' && purpose != 'JobCompletion') {
      throw ArgumentError('غرض التحقق غير صالح');
    }

    await _client.post(
      ApiConstants.requestBookingVerificationCode(intId),
      queryParameters: {'purpose': purpose},
    );
  }

  @override
  Future<BookingModel> verifyBookingCode(String bookingId, String purpose, String code) async {
    final intId = int.tryParse(bookingId);
    if (intId == null) throw ArgumentError('معرف الحجز غير صالح');
    if (code.trim().isEmpty) throw ArgumentError('رمز التحقق مطلوب');

    final response = await _client.post(
      ApiConstants.verifyBookingCode(intId),
      queryParameters: {'purpose': purpose},
      body: code.trim(),
    );
    if (response is! Map<String, dynamic>) throw StateError('استجابة تحقق الحجز غير صالحة');
    return _mapBooking(response);
  }

  BookingModel _mapBooking(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      requestId: json['serviceRequestId']?.toString() ?? '',
      serviceNameAr: json['serviceNameAr']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      technicianId: json['technicianId']?.toString() ?? '',
      technicianName: json['technicianName']?.toString() ?? '',
      address: AddressModel.fromJson(json['address'] is Map ? json['address'] as Map<String, dynamic> : {}),
      scheduledDate: json['acceptedAt']?.toString() ?? '',
      scheduledTime: '',
      price: ((json['finalPrice'] ?? json['agreedPrice']) as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.fromString(json['status']?.toString() ?? 'Confirmed'),
      createdAt: json['acceptedAt']?.toString() ?? '',
      completedAt: json['completedAt']?.toString(),
      notes: json['technicianNotes']?.toString(),
    );
  }
}
