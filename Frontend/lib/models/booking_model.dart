import 'address_model.dart';

enum BookingStatus {
  upcoming,
  inProgress,
  completed,
  cancelled;

  String get displayNameAr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'قادمة ومجدولة';
      case BookingStatus.inProgress:
        return 'جاري العمل';
      case BookingStatus.completed:
        return 'مكتملة';
      case BookingStatus.cancelled:
        return 'ملغاة';
    }
  }

  static BookingStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }

  String get nameStr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.inProgress:
        return 'InProgress';
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestId': requestId,
        'serviceNameAr': serviceNameAr,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'address': address.toJson(),
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'price': price,
        'status': status.nameStr,
        'createdAt': createdAt,
        'completedAt': completedAt,
        'notes': notes,
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] ?? '',
        requestId: json['requestId'] ?? '',
        serviceNameAr: json['serviceNameAr'] ?? '',
        customerName: json['customerName'] ?? '',
        customerPhone: json['customerPhone'] ?? '',
        technicianId: json['technicianId'] ?? '',
        technicianName: json['technicianName'] ?? '',
        address: AddressModel.fromJson(json['address'] ?? {}),
        scheduledDate: json['scheduledDate'] ?? '',
        scheduledTime: json['scheduledTime'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        status: BookingStatus.fromString(json['status'] ?? 'Upcoming'),
        createdAt: json['createdAt'] ?? '',
        completedAt: json['completedAt'],
        notes: json['notes'],
      );
}
