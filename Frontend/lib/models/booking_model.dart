import 'address_model.dart';

enum BookingStatus {
  upcoming,
  arrived,
  inProgress,
  awaitingCompletion,
  completed,
  cancelled;

  String get displayNameAr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'مؤكدة';
      case BookingStatus.arrived:
        return 'الفني وصل';
      case BookingStatus.inProgress:
        return 'جاري العمل';
      case BookingStatus.awaitingCompletion:
        return 'بانتظار تأكيد الإكمال';
      case BookingStatus.completed:
        return 'مكتملة';
      case BookingStatus.cancelled:
        return 'ملغاة';
    }
  }

  static BookingStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'arrived':
        return BookingStatus.arrived;
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'awaitingcompletion':
        return BookingStatus.awaitingCompletion;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      case 'confirmed':
      default:
        return BookingStatus.upcoming;
    }
  }

  String get nameStr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Confirmed';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.inProgress:
        return 'InProgress';
      case BookingStatus.awaitingCompletion:
        return 'AwaitingCompletion';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class BookingModel {
  final String id;
  final String requestId;
  final String serviceNameAr;
  final String customerName;
  final String customerPhone;
  final String technicianId;
  final String technicianName;
  final AddressModel address;
  final String scheduledDate;
  final String scheduledTime;
  final double price;
  final BookingStatus status;
  final String createdAt;
  final String? completedAt;
  final String? notes;

  BookingModel({
    required this.id,
    required this.requestId,
    required this.serviceNameAr,
    required this.customerName,
    required this.customerPhone,
    required this.technicianId,
    required this.technicianName,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.price,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  BookingModel copyWith({
    String? id,
    String? requestId,
    String? serviceNameAr,
    String? customerName,
    String? customerPhone,
    String? technicianId,
    String? technicianName,
    AddressModel? address,
    String? scheduledDate,
    String? scheduledTime,
    double? price,
    BookingStatus? status,
    String? createdAt,
    String? completedAt,
    String? notes,
  }) {
    return BookingModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      address: address ?? this.address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}
