import 'user_model.dart';

enum NotificationType {
  requestAccepted,
  statusUpdate,
  newMessage,
  bookingScheduled,
  paymentReceived,
  system;

  String get displayNameAr {
    switch (this) {
      case NotificationType.requestAccepted:
        return 'قبول طلب';
      case NotificationType.statusUpdate:
        return 'تحديث حالة';
      case NotificationType.newMessage:
        return 'رسالة جديدة';
      case NotificationType.bookingScheduled:
        return 'جدولة موعد';
      case NotificationType.paymentReceived:
        return 'دفعة مالية';
      case NotificationType.system:
        return 'تنبيه نظام';
    }
  }

  static NotificationType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'requestaccepted':
        return NotificationType.requestAccepted;
      case 'newmessage':
        return NotificationType.newMessage;
      case 'bookingscheduled':
        return NotificationType.bookingScheduled;
      case 'paymentreceived':
        return NotificationType.paymentReceived;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.statusUpdate;
    }
  }

  String get nameStr {
    switch (this) {
      case NotificationType.requestAccepted:
        return 'RequestAccepted';
      case NotificationType.statusUpdate:
        return 'StatusUpdate';
      case NotificationType.newMessage:
        return 'NewMessage';
      case NotificationType.bookingScheduled:
        return 'BookingScheduled';
      case NotificationType.paymentReceived:
        return 'PaymentReceived';
      case NotificationType.system:
        return 'System';
    }
  }
}

class NotificationModel {
  final String id;
  final String recipientId;
  final UserRole recipientRole;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.recipientRole,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    UserRole? recipientRole,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientRole: recipientRole ?? this.recipientRole,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientId': recipientId,
        'recipientRole': recipientRole.nameStr,
        'title': title,
        'message': message,
        'type': type.nameStr,
        'relatedId': relatedId,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] ?? '',
        recipientId: json['recipientId'] ?? '',
        recipientRole: UserRole.fromString(json['recipientRole'] ?? 'Customer'),
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        type: NotificationType.fromString(json['type'] ?? 'StatusUpdate'),
        relatedId: json['relatedId'],
        createdAt: json['createdAt'] ?? '',
        isRead: json['isRead'] ?? false,
      );
}
