import 'api_dtos.dart';

enum PaymentMethodType {
  card,
  mobileWallet,
  cashOnDelivery,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get nameStr {
    switch (this) {
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.mobileWallet:
        return 'MobileWallet';
      case PaymentMethodType.cashOnDelivery:
        return 'CashOnDelivery';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PaymentMethodType.card:
        return 'بطاقة بنكية (Visa / MasterCard / ميزة)';
      case PaymentMethodType.mobileWallet:
        return 'محفظة إلكترونية (فودافون كاش ومحافظ مصر)';
      case PaymentMethodType.cashOnDelivery:
        return 'الدفع نقداً بعد المعاينة / الإنجاز';
    }
  }

  static PaymentMethodType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'card':
      case 'creditcard':
      case 'debitcard':
      case 'visa':
      case 'mastercard':
        return PaymentMethodType.card;
      case 'mobilewallet':
      case 'wallet':
      case 'vodafonecash':
      case 'vodafone':
        return PaymentMethodType.mobileWallet;
      case 'cashondelivery':
      case 'cash':
      default:
        return PaymentMethodType.cashOnDelivery;
    }
  }
}

enum PaymentStatusType {
  pending,
  processing,
  paid,
  failed,
  refunded,
  cancelled,
}

extension PaymentStatusTypeExtension on PaymentStatusType {
  String get nameStr {
    switch (this) {
      case PaymentStatusType.pending:
        return 'Pending';
      case PaymentStatusType.processing:
        return 'Processing';
      case PaymentStatusType.paid:
        return 'Paid';
      case PaymentStatusType.failed:
        return 'Failed';
      case PaymentStatusType.refunded:
        return 'Refunded';
      case PaymentStatusType.cancelled:
        return 'Cancelled';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PaymentStatusType.pending:
        return 'بانتظار الدفع';
      case PaymentStatusType.processing:
        return 'جاري التحقق';
      case PaymentStatusType.paid:
        return 'تم الدفع بنجاح';
      case PaymentStatusType.failed:
        return 'فشلت عملية الدفع';
      case PaymentStatusType.refunded:
        return 'مسترد';
      case PaymentStatusType.cancelled:
        return 'ملغي';
    }
  }

  static PaymentStatusType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
        return PaymentStatusType.paid;
      case 'processing':
        return PaymentStatusType.processing;
      case 'failed':
      case 'declined':
        return PaymentStatusType.failed;
      case 'refunded':
        return PaymentStatusType.refunded;
      case 'cancelled':
      case 'canceled':
        return PaymentStatusType.cancelled;
      case 'pending':
      default:
        return PaymentStatusType.pending;
    }
  }
}

class PaymentModel {
  final String id;
  final String serviceRequestId;
  final String? bookingId;
  final String? customerId;
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final PaymentStatusType status;
  final String? paymentType; // VisitFee, FullService
  final String? gatewayProvider; // Paymob
  final String? transactionReference;
  final String? gatewayOrderId;
  final String? paymentToken;
  final String? iframeUrl;
  final String? redirectUrl;
  final String? paidAt;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.serviceRequestId,
    this.bookingId,
    this.customerId,
    required this.amount,
    this.currency = 'EGP',
    required this.method,
    required this.status,
    this.paymentType = 'FullService',
    this.gatewayProvider = 'Paymob',
    this.transactionReference,
    this.gatewayOrderId,
    this.paymentToken,
    this.iframeUrl,
    this.redirectUrl,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromDto(PaymentDto dto) {
    return PaymentModel(
      id: dto.id.toString(),
      serviceRequestId: dto.serviceRequestId.toString(),
      amount: dto.amount,
      currency: 'EGP',
      method: PaymentMethodTypeExtension.fromString(dto.paymentMethod),
      status: PaymentStatusTypeExtension.fromString(dto.status),
      paymentType: dto.paymentType ?? 'FullService',
      transactionReference: dto.transactionReference,
      paidAt: dto.paidAt,
      createdAt: dto.createdAt,
    );
  }

  factory PaymentModel.fromInitiateResponse(InitiatePaymentResponse resp, String serviceReqId, double amt) {
    return PaymentModel(
      id: resp.paymentId.toString(),
      serviceRequestId: serviceReqId,
      amount: resp.amount > 0 ? resp.amount : amt,
      currency: resp.currency,
      method: PaymentMethodTypeExtension.fromString(resp.paymentMethod),
      status: PaymentStatusTypeExtension.fromString(resp.status),
      gatewayOrderId: resp.gatewayOrderId,
      paymentToken: resp.paymentToken,
      iframeUrl: resp.iframeUrl,
      redirectUrl: resp.redirectUrl,
      transactionReference: resp.transactionReference,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  PaymentModel copyWith({
    String? id,
    String? serviceRequestId,
    String? bookingId,
    String? customerId,
    double? amount,
    String? currency,
    PaymentMethodType? method,
    PaymentStatusType? status,
    String? paymentType,
    String? gatewayProvider,
    String? transactionReference,
    String? gatewayOrderId,
    String? paymentToken,
    String? iframeUrl,
    String? redirectUrl,
    String? paidAt,
    String? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentType: paymentType ?? this.paymentType,
      gatewayProvider: gatewayProvider ?? this.gatewayProvider,
      transactionReference: transactionReference ?? this.transactionReference,
      gatewayOrderId: gatewayOrderId ?? this.gatewayOrderId,
      paymentToken: paymentToken ?? this.paymentToken,
      iframeUrl: iframeUrl ?? this.iframeUrl,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
