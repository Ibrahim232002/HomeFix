import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IPaymentRepository {
  Future<PaymentDto> getPaymentById(int id);
  Future<List<PaymentDto>> getPaymentsByRequestId(int serviceRequestId);
  Future<PaymentDto> createPayment(CreatePaymentRequest request);
  Future<PaymentDto> updatePayment(int id, UpdatePaymentRequest request);
  Future<InitiatePaymentResponse> initiatePayment(InitiatePaymentRequest request);
  Future<VerifyPaymentResponse> verifyPayment(int paymentId);
  Future<VerifyPaymentResponse> inquirePaymentByReference(String reference);
  Future<PaymentDto> setCashPayment(int serviceRequestId);
}

class PaymentRepository implements IPaymentRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<PaymentDto> getPaymentById(int id) async {
    final response = await _client.get(ApiConstants.paymentById(id));
    return PaymentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<PaymentDto>> getPaymentsByRequestId(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.paymentsByRequest(serviceRequestId));
    if (response is List) {
      return response.map((item) => PaymentDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<PaymentDto> createPayment(CreatePaymentRequest request) async {
    final response = await _client.post(ApiConstants.payments, body: request.toJson());
    return PaymentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PaymentDto> updatePayment(int id, UpdatePaymentRequest request) async {
    final response = await _client.put(ApiConstants.paymentById(id), body: request.toJson());
    return PaymentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<InitiatePaymentResponse> initiatePayment(InitiatePaymentRequest request) async {
    final response = await _client.post(ApiConstants.initiatePayment, body: request.toJson());
    return InitiatePaymentResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<VerifyPaymentResponse> verifyPayment(int paymentId) async {
    final response = await _client.get(ApiConstants.verifyPayment(paymentId));
    return VerifyPaymentResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<VerifyPaymentResponse> inquirePaymentByReference(String reference) async {
    final response = await _client.get(ApiConstants.inquirePaymentByReference(reference));
    return VerifyPaymentResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PaymentDto> setCashPayment(int serviceRequestId) async {
    final response = await _client.post(ApiConstants.setCashPayment(serviceRequestId));
    return PaymentDto.fromJson(response as Map<String, dynamic>);
  }
}
