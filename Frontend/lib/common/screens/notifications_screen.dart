import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final INotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = const [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthSessionProvider>().user;
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifications = await _repository.getUserNotifications(user.id);
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _markRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      await _repository.markAsRead(notification.id);
      if (!mounted) return;
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index >= 0) {
        final updated = List<NotificationModel>.from(_notifications);
        updated[index] = notification.copyWith(isRead: true);
        setState(() => _notifications = updated);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll) return;
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;
    setState(() => _markingAll = true);
    try {
      for (final notification in unread) {
        await _repository.markAsRead(notification.id);
      }
      if (!mounted) return;
      setState(() {
        _markingAll = false;
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _markingAll = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = ListView(children: const [SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))]);
    } else if (_error != null) {
      body = ListView(children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppColors.errorLight,
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: AppColors.errorDark),
              title: Text(_error!),
              trailing: TextButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ),
          ),
        ),
      ]);
    } else if (_notifications.isEmpty) {
      body = ListView(
        children: [
          const SizedBox(height: 180),
          Center(
            child: EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'لا توجد إشعارات',
              description: 'ستظهر هنا التنبيهات القادمة من الخادم.',
            ),
          ),
        ],
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            color: notification.isRead ? Colors.white : AppColors.primarySurface,
            child: ListTile(
              onTap: () => _markRead(notification),
              leading: Icon(notification.isRead ? Icons.notifications_none : Icons.notifications_active, color: AppColors.primary),
              title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800)),
              subtitle: Text(notification.message),
              trailing: notification.isRead ? null : const Icon(Icons.circle, size: 9, color: AppColors.primary),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التنبيهات والإشعارات'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markingAll ? null : _markAllRead,
              child: _markingAll ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('تحديد الكل كمقروء'),
            ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: body),
    );
  }
}
