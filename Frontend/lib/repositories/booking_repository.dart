import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/booking_model.dart';
import '../models/address_model.dart';

abstract class IBookingRepository {
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId);
  Future<List<BookingModel>> getBookingsByCustomer(String customerId);
  Future<BookingModel?> getBookingById(String id);
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<BookingModel> createBooking(BookingModel booking);

  // Direct OpenAPI DTO methods
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
      // Use the raw response here so the technician UI receives the authoritative
      // backend Booking.Status instead of deriving a broad state from timestamps.
      final response = await _client.get(ApiConstants.bookingsByTechnician(intId));
      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map(_mapRawJsonToModel)
            .toList();
      }
      return [];
    } catch (_) {
      // Preserve existing read semantics; transition failures are intentionally
      // not swallowed in updateBookingStatus below.
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

    try {
      final response = await _client.get(ApiConstants.bookingById(intId));
      if (response is Map<String, dynamic>) {
        return _mapRawJsonToModel(response);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final intId = int.tryParse(bookingId);
    if (intId == null || intId <= 0) {
      throw Exception('معرف الحجز غير صالح');
    }

    // Technician execution MUST use the dedicated transition endpoint. The generic
    // PUT /api/Bookings/{id} remains an Admin API and is intentionally not used here.
    final response = await _client.post(
      ApiConstants.bookingTransition(intId),
      body: {'status': newStatus.nameStr},
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('استجابة انتقال حالة الحجز غير صالحة');
    }

    // Parse the authoritative response immediately. AppStateProvider already
    // reloads centralized technician bookings after this method succeeds.
    return _mapRawJsonToModel(response);
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final requestId = int.tryParse(booking.requestId);
    final technicianId = int.tryParse(booking.technicianId);

    if (requestId == null || technicianId == null) {
      throw Exception('بيانات الحجز غير صالحة');
    }

    final dto = await createApiBooking(CreateBookingRequest(
      serviceRequestId: requestId,
      technicianId: technicianId,
    ));
    return _mapDtoToModel(dto, fallback: booking);
  }

  BookingModel _mapRawJsonToModel(
    Map<String, dynamic> json, {
    BookingModel? fallback,
  }) {
    return BookingModel(
      id: json['id']?.toString() ?? fallback?.id ?? '',
      requestId: json['serviceRequestId']?.toString() ?? fallback?.requestId ?? '',
      serviceNameAr: fallback?.serviceNameAr ?? '',
      customerName: fallback?.customerName ?? '',
      customerPhone: fallback?.customerPhone ?? '',
      technicianId: json['technicianId']?.toString() ?? fallback?.technicianId ?? '',
      technicianName: fallback?.technicianName ?? '',
      address: fallback?.address ??
          AddressModel(
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
      scheduledDate: json['acceptedAt']?.toString() ?? fallback?.scheduledDate ?? '',
      scheduledTime: fallback?.scheduledTime ?? '',
      price: (json['finalPrice'] as num?)?.toDouble() ??
          (json['agreedPrice'] as num?)?.toDouble() ??
          fallback?.price ??
          0.0,
      status: BookingStatus.fromString(json['status']?.toString() ?? 'Unknown'),
      createdAt: json['acceptedAt']?.toString() ?? fallback?.createdAt ?? '',
      completedAt: json['completedAt']?.toString(),
      notes: json['technicianNotes']?.toString(),
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
      address: fallback?.address ??
          AddressModel(
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
      scheduledDate: dto.acceptedAt ?? fallback?.scheduledDate ?? '',
      scheduledTime: fallback?.scheduledTime ?? '',
      price: dto.finalPrice ?? fallback?.price ?? 0.0,
      status: legacyStatus,
      createdAt: dto.acceptedAt ?? fallback?.createdAt ?? '',
      completedAt: dto.completedAt,
      notes: dto.technicianNotes,
    );
  }

  // --- Direct OpenAPI Implementations ---
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
    if (response is List) {
      return response
          .map((item) => BookingDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
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
