import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
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
    return response.map((item) => _mapDto(ServiceRequestDto.fromJson(item as Map<String, dynamic>))).toList();
  }

  @override
  Future<List<ServiceRequestModel>> getAvailableRequestsForTechnicians({String? serviceId, String? governorate}) async {
    final response = await _client.get(ApiConstants.technicianAvailableRequests);
    if (response is! List) return [];
    return response.map((item) => _mapDto(ServiceRequestDto.fromJson(item as Map<String, dynamic>))).toList();
  }

  @override
  Future<ServiceRequestModel?> getRequestById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final response = await _client.get(ApiConstants.serviceRequestById(intId));
    if (response is! Map<String, dynamic>) return null;
    return _mapDto(ServiceRequestDto.fromJson(response));
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
        'preferredDate': request.preferredDate,
        'preferredTime': request.preferredTime,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw StateError('استجابة إنشاء طلب الخدمة غير صالحة');
    }
    return _mapDto(ServiceRequestDto.fromJson(response), fallback: request);
  }

  @override
  Future<void> updateStatus(String requestId, ServiceRequestStatus newStatus, {String? notes, String? updatedBy}) async {
    throw UnsupportedError(
      'Service request status changes are controlled by the current backend workflow and are not a customer/technician PUT operation.',
    );
  }

  @override
  Future<void> cancelRequest(String requestId, String reason) async {
    throw UnsupportedError(
      'Request cancellation is not exposed by the current ServiceRequests API contract.',
    );
  }

  @override
  Future<void> assignTechnician(String requestId, String technicianId, String technicianName) async {
    throw UnsupportedError(
      'Technician assignment is performed by offer acceptance on the current backend.',
    );
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

  ServiceRequestModel _mapDto(ServiceRequestDto dto, {ServiceRequestModel? fallback}) {
    final status = ServiceRequestStatus.fromString(dto.status ?? 'Open');
    return ServiceRequestModel(
      id: dto.id.toString(),
      serviceId: dto.serviceId.toString(),
      serviceNameAr: fallback?.serviceNameAr ?? 'طلب #${dto.serviceId}',
      categoryNameAr: fallback?.categoryNameAr ?? '',
      customerId: dto.customerId.toString(),
      customerName: fallback?.customerName ?? '',
      customerPhone: fallback?.customerPhone ?? '',
      address: fallback?.address ?? AddressModel(
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
      preferredDate: dto.preferredDate?.toString() ?? '',
      preferredTime: dto.preferredTime?.toString() ?? '',
      files: fallback?.files ?? [],
      status: status,
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
