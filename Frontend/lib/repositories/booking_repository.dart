import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/booking_model.dart';
import '../models/address_model.dart';

abstract class IBookingRepository {
  Future<List<BookingModel>> getBookingsByTechnician(String technicianId);
  Future<List<BookingModel>> getBookingsByCustomer(String customerId);
  Future<BookingModel?> getBookingById(String id);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
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
    if (intId != null) {
      try {
        final dtos = await getApiBookingsByTechnician(intId);
        return dtos.map((d) => _mapDtoToModel(d)).toList();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<List<BookingModel>> getBookingsByCustomer(String customerId) async {
    final intId = int.tryParse(customerId);
    if (intId != null) {
      try {
        // Fetch customer's service requests to check for attached bookings
        final reqResponse = await _client.get(ApiConstants.serviceRequestsByCustomer(intId));
        if (reqResponse is List) {
          final List<BookingModel> customerBookings = [];
          for (final reqJson in reqResponse) {
            final reqDto = ServiceRequestDto.fromJson(reqJson as Map<String, dynamic>);
            try {
              final bookingDto = await getApiBookingByRequest(reqDto.id);
              customerBookings.add(_mapDtoToModel(bookingDto));
            } catch (_) {}
          }
          return customerBookings;
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      try {
        final dto = await getApiBookingById(intId);
        return _mapDtoToModel(dto);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final intId = int.tryParse(bookingId);
    if (intId != null) {
      try {
        final now = DateTime.now().toIso8601String();
        await updateApiBooking(
          intId,
          UpdateBookingRequest(
            acceptedAt: newStatus == BookingStatus.upcoming ? now : null,
            startedAt: newStatus == BookingStatus.inProgress ? now : null,
            completedAt: newStatus == BookingStatus.completed ? now : null,
          ),
        );
      } catch (_) {}
    }
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

  BookingModel _mapDtoToModel(BookingDto dto, {BookingModel? fallback}) {
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
      scheduledDate: dto.acceptedAt ?? '',
      scheduledTime: '',
      price: dto.finalPrice ?? 0.0,
      status: dto.completedAt != null
          ? BookingStatus.completed
          : dto.startedAt != null
              ? BookingStatus.inProgress
              : BookingStatus.upcoming,
      createdAt: dto.acceptedAt ?? '',
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
      return response.map((item) => BookingDto.fromJson(item as Map<String, dynamic>)).toList();
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
