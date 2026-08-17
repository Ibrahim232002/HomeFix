import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IPaymentRepository {
  Future<PaymentDto> getPaymentById(int id);
  Future<List<PaymentDto>> getPaymentsByRequestId(int serviceRequestId);
  Future<double> getPayableAmountByRequest(int serviceRequestId);
  Future<PaymentDto> setCashPayment(int serviceRequestId);

  /// The current backend exposes card/gateway creation only as an Admin endpoint.
  /// Keep these methods explicit so the UI cannot pretend a customer gateway flow exists.
  Future<InitiatePaymentResponse> initiatePayment(InitiatePaymentRequest request);
  Future<VerifyPaymentResponse> verifyPayment(int paymentId);
  Future<VerifyPaymentResponse> inquirePaymentByReference(String reference);
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
    if (response is! List) return [];
    return response
        .map((item) => PaymentDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double> getPayableAmountByRequest(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.payableAmountByRequest(serviceRequestId));
    if (response is! Map<String, dynamic>) {
      throw StateError('استجابة المبلغ المستحق غير صالحة');
    }
    final amount = response['amount'];
    if (amount is num) return amount.toDouble();
    throw StateError('المبلغ المستحق غير صالح');
  }

  @override
  Future<PaymentDto> setCashPayment(int serviceRequestId) async {
    final response = await _client.post(ApiConstants.setCashPayment(serviceRequestId));
    return PaymentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<InitiatePaymentResponse> initiatePayment(InitiatePaymentRequest request) async {
    throw UnsupportedError(
      'Card/mobile-wallet gateway initiation is not exposed to customers by the current backend API.',
    );
  }

  @override
  Future<VerifyPaymentResponse> verifyPayment(int paymentId) async {
    throw UnsupportedError(
      'Gateway payment verification is not exposed by the current backend API.',
    );
  }

  @override
  Future<VerifyPaymentResponse> inquirePaymentByReference(String reference) async {
    throw UnsupportedError(
      'Gateway payment inquiry is not exposed by the current backend API.',
    );
  }
}
