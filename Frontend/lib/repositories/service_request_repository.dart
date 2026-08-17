import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/service_request_api_dto.dart';
import '../models/service_request_model.dart';
import '../models/address_model.dart';

abstract class IServiceRequestRepository {
  Future<List<ServiceRequestModel>> getRequestsByCustomer(String customerId);
  Future<List<ServiceRequestModel>> getAvailableRequestsForTechnicians({String? serviceId, String? governorate});
  Future<ServiceRequestModel?> getRequestById(String id);
  Future<ServiceRequestModel> createRequest(ServiceRequestModel request);
  Future<void> updateStatus(String requestId, ServiceRequestStatus newStatus, {String? notes, String? updatedBy});
  Future<void> cancelRequest(String requestId, String reason);
  Future<void> assignTechnician(String requestId, String technicianId, String technicianName);
  Future<List<ServiceRequestFileDto>> getFiles(int serviceRequestId);
  Future<ServiceRequestFileDto> addFile(CreateServiceRequestFileRequest request);
  Future<void> deleteFile(int id);
  Future<List<ServiceRequestStatusHistoryDto>> getStatusHistory(int serviceRequestId);
  Future<ServiceRequestStatusHistoryDto> addStatusHistory(CreateServiceRequestStatusHistoryRequest request);
}

class ServiceRequestRepository implements IServiceRequestRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<ServiceRequestModel>> getRequestsByCustomer(String customerId) async {
    final intId = int.tryParse(customerId);
    if (intId == null) return [];
    final response = await _client.get(ApiConstants.serviceRequestsByCustomer(intId));
    if (response is! List) return [];
    return response
        .map((item) => _mapDto(ServiceRequestApiDto.fromJson(item as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<List<ServiceRequestModel>> getAvailableRequestsForTechnicians({String? serviceId, String? governorate}) async {
    final response = await _client.get(ApiConstants.technicianAvailableRequests);
    if (response is! List) return [];
    return response
        .map((item) => _mapDto(ServiceRequestApiDto.fromJson(item as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<ServiceRequestModel?> getRequestById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final response = await _client.get(ApiConstants.serviceRequestById(intId));
    if (response is! Map<String, dynamic>) return null;
    return _mapDto(ServiceRequestApiDto.fromJson(response));
  }

  @override
  Future<ServiceRequestModel> createRequest(ServiceRequestModel request) async {
    final serviceId = int.tryParse(request.serviceId);
    final addressId = int.tryParse(request.address.id);
    if (serviceId == null || addressId == null) {
      throw ArgumentError('بيانات الخدمة أو العنوان غير صالحة');
    }

    final response = await _client.post(
      ApiConstants.serviceRequests,
      body: {
        'serviceId': serviceId,
        'addressId': addressId,
        'description': request.problemDescription.trim(),
        'preferredDate': _normalizeDate(request.preferredDate),
        'preferredTime': _normalizeTime(request.preferredTime),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw StateError('استجابة إنشاء طلب الخدمة غير صالحة');
    }
    return _mapDto(ServiceRequestApiDto.fromJson(response), fallback: request);
  }

  String _normalizeDate(String value) {
    final trimmed = value.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return trimmed;

    final now = DateTime.now();
    if (trimmed == 'اليوم') return _dateOnly(now);
    if (trimmed == 'غداً' || trimmed == 'غدا') return _dateOnly(now.add(const Duration(days: 1)));
    if (trimmed == 'بعد غد' || trimmed == 'بعد غدا') return _dateOnly(now.add(const Duration(days: 2)));
    throw FormatException('تاريخ الزيارة غير صالح: $value');
  }

  String _normalizeTime(String value) {
    final trimmed = value.trim();
    if (RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(trimmed)) {
      return trimmed.length == 5 ? '$trimmed:00' : trimmed;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(صباحاً|صباحا|مساءً|مساء|ظهراً|ظهرا)$').firstMatch(trimmed);
    if (match == null) throw FormatException('توقيت الزيارة غير صالح: $value');

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!;
    final isPm = period.contains('مساء') || period.contains('ظهر');
    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  Future<void> updateStatus(String requestId, ServiceRequestStatus newStatus, {String? notes, String? updatedBy}) async {
    throw UnsupportedError('Service request status changes are controlled by the current backend workflow.');
  }

  @override
  Future<void> cancelRequest(String requestId, String reason) async {
    throw UnsupportedError('Request cancellation is not exposed by the current ServiceRequests API contract.');
  }

  @override
  Future<void> assignTechnician(String requestId, String technicianId, String technicianName) async {
    throw UnsupportedError('Technician assignment is performed by offer acceptance on the current backend.');
  }

  @override
  Future<List<ServiceRequestFileDto>> getFiles(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.serviceRequestFilesByRequest(serviceRequestId));
    if (response is! List) return [];
    return response.map((item) => ServiceRequestFileDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceRequestFileDto> addFile(CreateServiceRequestFileRequest request) async {
    final response = await _client.post(ApiConstants.serviceRequestFiles, body: request.toJson());
    return ServiceRequestFileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFile(int id) async {
    await _client.delete(ApiConstants.serviceRequestFileById(id));
  }

  @override
  Future<List<ServiceRequestStatusHistoryDto>> getStatusHistory(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.serviceRequestStatusHistoryByRequest(serviceRequestId));
    if (response is! List) return [];
    return response.map((item) => ServiceRequestStatusHistoryDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceRequestStatusHistoryDto> addStatusHistory(CreateServiceRequestStatusHistoryRequest request) async {
    final response = await _client.post(ApiConstants.serviceRequestStatusHistory, body: request.toJson());
    return ServiceRequestStatusHistoryDto.fromJson(response as Map<String, dynamic>);
  }

  ServiceRequestModel _mapDto(ServiceRequestApiDto dto, {ServiceRequestModel? fallback}) {
    final hasServerAddress = dto.fullAddress?.isNotEmpty == true ||
        dto.addressLabel?.isNotEmpty == true ||
        dto.cityName?.isNotEmpty == true;

    return ServiceRequestModel(
      id: dto.id.toString(),
      serviceId: dto.serviceId.toString(),
      serviceNameAr: dto.serviceName?.isNotEmpty == true
          ? dto.serviceName!
          : fallback?.serviceNameAr ?? '',
      categoryNameAr: fallback?.categoryNameAr ?? '',
      customerId: dto.customerId.toString(),
      customerName: fallback?.customerName ?? '',
      customerPhone: fallback?.customerPhone ?? '',
      address: hasServerAddress
          ? AddressModel(
              id: dto.addressId.toString(),
              userId: dto.customerId.toString(),
              title: dto.addressLabel?.isNotEmpty == true ? dto.addressLabel! : 'العنوان',
              governorate: dto.governorateName ?? '',
              city: dto.cityName ?? '',
              street: dto.fullAddress ?? '',
              building: dto.buildingNumber ?? '',
              floor: dto.floorNumber ?? '',
              apartment: dto.apartmentNumber ?? '',
              landmark: dto.additionalInstructions,
              isDefault: false,
              governorateId: dto.governorateId,
              cityId: dto.cityId,
            )
          : fallback?.address ?? AddressModel(
              id: dto.addressId.toString(),
              userId: dto.customerId.toString(),
              title: 'العنوان',
              governorate: '',
              city: '',
              street: '',
              building: '',
              floor: '',
              apartment: '',
            ),
      problemDescription: dto.description ?? '',
      preferredDate: dto.preferredDate ?? '',
      preferredTime: dto.preferredTime ?? '',
      files: fallback?.files ?? [],
      status: ServiceRequestStatus.fromString(dto.status ?? 'Open'),
      estimatedPriceMin: dto.visitFee,
      estimatedPriceMax: dto.visitFee,
      finalPrice: fallback?.finalPrice,
      createdAt: dto.createdAt,
      statusHistory: fallback?.statusHistory ?? [],
      cancellationReason: fallback?.cancellationReason,
      notes: fallback?.notes,
    );
  }
}
