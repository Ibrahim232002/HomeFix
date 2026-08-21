import 'address_model.dart';

enum BookingStatus {
  // Legacy name retained for existing UI code. It maps to the backend's Confirmed state.
  upcoming,
  technicianOnTheWay,
  arrived,
  inProgress,
  awaitingCompletion,
  completed,
  cancelled,
  unknown;

  String get displayNameAr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'قادمة ومؤكدة';
      case BookingStatus.technicianOnTheWay:
        return 'الفني في الطريق';
      case BookingStatus.arrived:
        return 'وصل الفني';
      case BookingStatus.inProgress:
        return 'جاري العمل';
      case BookingStatus.awaitingCompletion:
        return 'بانتظار تأكيد العميل';
      case BookingStatus.completed:
        return 'مكتملة';
      case BookingStatus.cancelled:
        return 'ملغاة';
      case BookingStatus.unknown:
        return 'حالة غير معروفة';
    }
  }

  String get nameStr {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Confirmed';
      case BookingStatus.technicianOnTheWay:
        return 'TechnicianOnTheWay';
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
      case BookingStatus.unknown:
        return 'Unknown';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'confirmed':
        return BookingStatus.upcoming;
      case 'technicianontheway':
        return BookingStatus.technicianOnTheWay;
      case 'arrived':
        return BookingStatus.arrived;
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'awaitingcompletion':
        return BookingStatus.awaitingCompletion;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.unknown;
    }
  }

  bool get isPreExecution =>
      this == BookingStatus.upcoming ||
      this == BookingStatus.technicianOnTheWay ||
      this == BookingStatus.arrived;

  bool get isActive =>
      this != BookingStatus.completed &&
      this != BookingStatus.cancelled &&
      this != BookingStatus.unknown;
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
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final double? agreedPrice;
  final double? finalPrice;
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
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.agreedPrice,
    this.finalPrice,
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
    String? acceptedAt,
    String? arrivedAt,
    String? startedAt,
    String? completedAt,
    double? agreedPrice,
    double? finalPrice,
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
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
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
        'acceptedAt': acceptedAt,
        'arrivedAt': arrivedAt,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'agreedPrice': agreedPrice,
        'finalPrice': finalPrice,
        'notes': notes,
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id']?.toString() ?? '',
        requestId: json['requestId']?.toString() ?? '',
        serviceNameAr: json['serviceNameAr']?.toString() ?? '',
        customerName: json['customerName']?.toString() ?? '',
        customerPhone: json['customerPhone']?.toString() ?? '',
        technicianId: json['technicianId']?.toString() ?? '',
        technicianName: json['technicianName']?.toString() ?? '',
        address: AddressModel.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
        scheduledDate: json['scheduledDate']?.toString() ?? '',
        scheduledTime: json['scheduledTime']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        status: BookingStatus.fromString(json['status']?.toString() ?? 'Unknown'),
        createdAt: json['createdAt']?.toString() ?? '',
        acceptedAt: json['acceptedAt']?.toString(),
        arrivedAt: json['arrivedAt']?.toString(),
        startedAt: json['startedAt']?.toString(),
        completedAt: json['completedAt']?.toString(),
        agreedPrice: (json['agreedPrice'] as num?)?.toDouble(),
        finalPrice: (json['finalPrice'] as num?)?.toDouble(),
        notes: json['notes']?.toString(),
      );
}
