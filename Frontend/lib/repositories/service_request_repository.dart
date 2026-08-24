import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/service_request_model.dart';
import '../models/address_model.dart';
import 'customer_profile_repository.dart';

abstract class IServiceRequestRepository {
  Future<List<ServiceRequestModel>> getRequestsByCustomer(String customerUserId);
  Future<List<ServiceRequestModel>> getAvailableRequestsForTechnicians({String? serviceId, String? governorate});
  Future<ServiceRequestModel?> getRequestById(String id);
  Future<ServiceRequestModel> createRequest(ServiceRequestModel request);
  Future<void> updateStatus(String requestId, ServiceRequestStatus newStatus, {String? notes, String? updatedBy});
  Future<void> cancelRequest(String requestId, String reason);

  Future<ServiceRequestDto> getApiServiceRequestById(int id);
  Future<List<ServiceRequestDto>> getApiServiceRequestsByCustomer(int customerId);
  Future<ServiceRequestDto> createApiServiceRequest(CreateServiceRequestRequest request);
  Future<void> updateApiServiceRequest(int id, dynamic requestBody);
  Future<List<ServiceRequestFileDto>> getFiles(int serviceRequestId);
  Future<ServiceRequestFileDto> addFile(CreateServiceRequestFileRequest request);
  Future<void> deleteFile(int id);
  Future<List<ServiceRequestStatusHistoryDto>> getStatusHistory(int serviceRequestId);
  Future<ServiceRequestStatusHistoryDto> addStatusHistory(CreateServiceRequestStatusHistoryRequest request);
}

class ServiceRequestRepository implements IServiceRequestRepository {
  final ApiClient _client = ApiClient();
  final CustomerProfileRepository _customerProfileRepo = CustomerProfileRepository();

  String _serializePreferredDate(String value) {
    switch (value.trim()) {
      case 'اليوم':
        return _formatDate(DateTime.now());
      case 'غداً':
        return _formatDate(DateTime.now().add(const Duration(days: 1)));
      case 'بعد غد':
        return _formatDate(DateTime.now().add(const Duration(days: 2)));
      default:
        final parsed = DateTime.tryParse(value.trim());
        if (parsed == null) throw FormatException('تاريخ الموعد غير صالح: $value');
        return _formatDate(parsed);
    }
  }

  String _serializePreferredTime(String value) {
    final normalized = value.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(صباحاً|مساءً|ظهراً)$').firstMatch(normalized);
    if (match == null) {
      final parsed = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$').firstMatch(normalized);
      if (parsed == null) throw FormatException('وقت الموعد غير صالح: $value');
      return '${parsed.group(1)}:${parsed.group(2)}:${parsed.group(3) ?? '00'}';
    }
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!;
    if (period == 'مساءً' && hour < 12) hour += 12;
    if (period == 'صباحاً' && hour == 12) hour = 0;
    if (period == 'ظهراً' && hour < 12) hour += 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDate(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  Future<List<ServiceRequestModel>> getRequestsByCustomer(String customerUserId) async {
    final userId = int.tryParse(customerUserId);
    if (userId == null || userId <= 0) throw Exception('معرف المستخدم غير صالح');
    final profile = await _customerProfileRepo.getProfileByUserId(userId);
    final dtos = await getApiServiceRequestsByCustomer(profile.id);
    return dtos.map((d) => _mapDtoToModel(d)).toList();
  }

  @override
  Future<List<ServiceRequestModel>> getAvailableRequestsForTechnicians({String? serviceId, String? governorate}) async {
    final response = await _client.get('/api/ServiceRequests/technician-available');
    if (response is List) {
      return response
          .map((item) => ServiceRequestDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => _mapDtoToModel(dto))
          .toList();
    }
    return [];
  }

  @override
  Future<ServiceRequestModel?> getRequestById(String id) async {
    final intId = int.tryParse(id);
    if (intId != null && intId > 0) {
      final dto = await getApiServiceRequestById(intId);
      return _mapDtoToModel(dto);
    }
    return null;
  }

  @override
  Future<ServiceRequestModel> createRequest(ServiceRequestModel request) async {
    final customerId = int.tryParse(request.customerId);
    final serviceId = int.tryParse(request.serviceId);
    final addressId = int.tryParse(request.address.id);
    if (customerId == null || customerId <= 0) throw FormatException('معرف العميل غير صالح');
    if (serviceId == null || serviceId <= 0) throw FormatException('معرف الخدمة غير صالح');
    if (addressId == null || addressId <= 0) throw FormatException('معرف العنوان غير صالح');
    final visitFee = request.visitFee;
    if (visitFee == null) throw FormatException('رسوم الزيارة غير محددة لطلب الخدمة');

    final dto = await createApiServiceRequest(CreateServiceRequestRequest(
      customerId: customerId,
      serviceId: serviceId,
      addressId: addressId,
      description: request.problemDescription,
      preferredDate: _serializePreferredDate(request.preferredDate),
      preferredTime: _serializePreferredTime(request.preferredTime),
      status: 'Pending',
      visitFee: visitFee,
    ));
    return _mapDtoToModel(dto, fallbackModel: request);
  }

  @override
  Future<void> updateStatus(String requestId, ServiceRequestStatus newStatus, {String? notes, String? updatedBy}) async {
    final intId = int.tryParse(requestId);
    if (intId != null && intId > 0) {
      await addStatusHistory(CreateServiceRequestStatusHistoryRequest(
        serviceRequestId: intId,
        oldStatus: 'Current',
        newStatus: newStatus.nameStr,
        changedByUserId: 1,
      ));
      await updateApiServiceRequest(intId, {'status': newStatus.nameStr});
    }
  }

  @override
  Future<void> cancelRequest(String requestId, String reason) async {
    final intId = int.tryParse(requestId);
    if (intId == null || intId <= 0) throw Exception('معرف طلب الخدمة غير صالح');
    await _client.post(ApiConstants.cancelServiceRequest(intId), body: {});
  }

  ServiceRequestModel _mapDtoToModel(ServiceRequestDto dto, {ServiceRequestModel? fallbackModel}) {
    final statusValue = dto.status;
    if (statusValue == null || statusValue.trim().isEmpty) throw FormatException('حالة طلب الخدمة غير موجودة.');
    final status = ServiceRequestStatus.fromString(statusValue);
    return ServiceRequestModel(
      id: dto.id.toString(),
      serviceId: dto.serviceId.toString(),
      serviceNameAr: fallbackModel?.serviceNameAr ?? 'طلب #${dto.serviceId}',
      categoryNameAr: fallbackModel?.categoryNameAr ?? '',
      customerId: dto.customerId.toString(),
      customerName: fallbackModel?.customerName ?? '',
      customerPhone: fallbackModel?.customerPhone ?? '',
      address: fallbackModel?.address ?? AddressModel(
        id: dto.addressId.toString(), userId: dto.customerId.toString(), title: '', governorate: '', city: '', street: '', building: '', floor: '', apartment: '',
      ),
      problemDescription: dto.description ?? '',
      preferredDate: dto.preferredDate ?? '',
      preferredTime: dto.preferredTime ?? '',
      files: [],
      status: status,
      visitFee: dto.visitFee,
      estimatedPriceMin: fallbackModel?.estimatedPriceMin ?? dto.visitFee ?? 0.0,
      estimatedPriceMax: fallbackModel?.estimatedPriceMax ?? dto.visitFee ?? 0.0,
      finalPrice: fallbackModel?.finalPrice,
      createdAt: dto.createdAt,
      statusHistory: [
        ServiceRequestStatusHistoryModel(
          status: status,
          timestamp: dto.createdAt,
          updatedBy: 'العميل',
        ),
      ],
    );
  }

  @override
  Future<ServiceRequestDto> getApiServiceRequestById(int id) async {
    final response = await _client.get(ApiConstants.serviceRequestById(id));
    return ServiceRequestDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceRequestDto>> getApiServiceRequestsByCustomer(int customerId) async {
    final response = await _client.get(ApiConstants.serviceRequestsByCustomer(customerId));
    if (response is List) return response.map((item) => ServiceRequestDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<ServiceRequestDto> createApiServiceRequest(CreateServiceRequestRequest request) async {
    final response = await _client.post(ApiConstants.serviceRequests, body: request.toJson());
    return ServiceRequestDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateApiServiceRequest(int id, dynamic requestBody) async {
    await _client.put(ApiConstants.serviceRequestById(id), body: requestBody);
  }

  @override
  Future<List<ServiceRequestFileDto>> getFiles(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.serviceRequestFilesByRequest(serviceRequestId));
    if (response is List) return response.map((item) => ServiceRequestFileDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
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
    if (response is List) return response.map((item) => ServiceRequestStatusHistoryDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<ServiceRequestStatusHistoryDto> addStatusHistory(CreateServiceRequestStatusHistoryRequest request) async {
    final response = await _client.post(ApiConstants.serviceRequestStatusHistory, body: request.toJson());
    return ServiceRequestStatusHistoryDto.fromJson(response as Map<String, dynamic>);
  }
}
