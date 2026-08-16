import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/notification_model.dart';
import '../../services/app_state_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.requestAccepted:
        return Icons.check_circle_outline_rounded;
      case NotificationType.statusUpdate:
        return Icons.build_circle_rounded;
      case NotificationType.newMessage:
        return Icons.chat_rounded;
      case NotificationType.bookingScheduled:
        return Icons.event_available_rounded;
      case NotificationType.paymentReceived:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final notifications = appState.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التنبيهات والإشعارات'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => appState.markAllNotificationsAsRead(),
              child: const Text(
                'تحديد الكل كمقروء',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'لا توجد إشعارات جديدة',
              description: 'سنوافيك فوراً بأي تحديثات على طلباتك ومواعيد الصيانة.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : AppColors.primarySurface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead ? AppColors.border : AppColors.primaryLight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () {
                      appState.markNotificationAsRead(notif.id);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: notif.isRead ? AppColors.scaffoldBackground : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(notif.type),
                        color: notif.isRead ? AppColors.textSecondary : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: notif.isRead ? FontWeight.w700 : FontWeight.w900,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        Text(
                          notif.createdAt,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notif.message,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
