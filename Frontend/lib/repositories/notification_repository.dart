import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<NotificationDto> getApiNotificationById(int id);
  Future<List<NotificationDto>> getApiNotificationsMe();
  Future<NotificationDto> createApiNotification(CreateNotificationRequest request);
  Future<void> markApiNotificationAsRead(int id);
}

class NotificationRepository implements INotificationRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId == null || intUserId <= 0) throw Exception('معرف المستخدم غير صالح');

    final dtos = await getApiNotificationsMe();
    return dtos
        .map((d) => NotificationModel(
              id: d.id.toString(),
              recipientId: d.userId.toString(),
              recipientRole: UserRole.customer,
              title: d.title ?? 'تنبيه',
              message: d.message ?? '',
              type: NotificationType.system,
              createdAt: d.createdAt.isNotEmpty ? d.createdAt : '',
              isRead: d.isRead,
            ))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final intId = int.tryParse(notificationId);
    if (intId == null || intId <= 0) throw Exception('معرف الإشعار غير صالح');
    await markApiNotificationAsRead(intId);
  }

  @override
  Future<NotificationDto> getApiNotificationById(int id) async {
    final response = await _client.get(ApiConstants.notificationById(id));
    return NotificationDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<NotificationDto>> getApiNotificationsMe() async {
    final response = await _client.get(ApiConstants.notificationsMe);
    if (response is List) {
      return response.map((item) => NotificationDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<NotificationDto> createApiNotification(CreateNotificationRequest request) async {
    final response = await _client.post(ApiConstants.notifications, body: request.toJson());
    return NotificationDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> markApiNotificationAsRead(int id) async {
    await _client.put(
      ApiConstants.notificationById(id),
      body: UpdateNotificationRequest(isRead: true).toJson(),
    );
  }
}
