import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
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
  String? _markingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safeError(Object error) => error is ApiException ? error.message : 'تعذر تحميل الإشعارات. يرجى المحاولة مرة أخرى.';

  Future<void> _load() async {
    final user = context.read<AuthSessionProvider>().user;
    if (user == null) return;
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final notifications = await _repository.getUserNotifications(user.id);
      if (!mounted) return;
      setState(() { _notifications = notifications; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _safeError(e); });
    }
  }

  Future<void> _markRead(NotificationModel notification) async {
    if (notification.isRead || _markingId == notification.id) return;
    setState(() => _markingId = notification.id);
    try {
      await _repository.markAsRead(notification.id);
      if (!mounted) return;
      final index = _notifications.indexWhere((item) => item.id == notification.id);
      if (index >= 0) {
        final updated = List<NotificationModel>.from(_notifications);
        updated[index] = notification.copyWith(isRead: true);
        setState(() { _notifications = updated; _markingId = null; });
      }
    } catch (e) {
      if (mounted) setState(() { _markingId = null; _error = _safeError(e); });
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll) return;
    final unread = _notifications.where((notification) => !notification.isRead).toList();
    if (unread.isEmpty) return;
    setState(() => _markingAll = true);
    try {
      for (final notification in unread) {
        await _repository.markAsRead(notification.id);
      }
      if (!mounted) return;
      setState(() { _markingAll = false; _notifications = _notifications.map((item) => item.copyWith(isRead: true)).toList(); });
    } catch (e) {
      if (mounted) setState(() { _markingAll = false; _error = _safeError(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final unreadCount = _notifications.where((notification) => !notification.isRead).length;

    Widget body;
    if (_loading) {
      body = ListView(padding: padding, children: const [HomeFixSkeletonList(itemCount: 6)]);
    } else if (_error != null && _notifications.isEmpty) {
      body = ListView(padding: padding, children: [SizedBox(height: 380, child: HomeFixErrorState(title: 'تعذر تحميل الإشعارات', message: _error, onRetry: _load))]);
    } else if (_notifications.isEmpty) {
      body = ListView(children: const [SizedBox(height: 220), HomeFixEmptyState(icon: Icons.notifications_none_rounded, title: 'لا توجد إشعارات', message: 'ستظهر هنا تنبيهات الحساب والطلبات والحجوزات.')]);
    } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding.add(const EdgeInsets.only(bottom: 24)),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDesignTokens.space3),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final marking = _markingId == notification.id;
          return AppResponsive.content(
            context,
            child: HomeFixCard(
              backgroundColor: notification.isRead ? AppColors.cardBackground : AppColors.primarySurface,
              borderColor: notification.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.25),
              onTap: notification.isRead ? null : () => _markRead(notification),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: notification.isRead ? AppColors.borderLight : AppColors.primaryLight, shape: BoxShape.circle),
                  child: Icon(notification.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded, color: AppColors.primaryDark),
                ),
                const SizedBox(width: AppDesignTokens.space3),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(notification.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800))),
                    if (!notification.isRead) const HomeFixStatusChip(label: 'جديد', tone: HomeFixStatusTone.info, icon: Icons.fiber_manual_record),
                  ]),
                  const SizedBox(height: AppDesignTokens.space2),
                  Text(notification.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  if (marking) ...[
                    const SizedBox(height: AppDesignTokens.space2),
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ])),
              ]),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الإشعارات'),
          if (unreadCount > 0) Text('$unreadCount غير مقروءة', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
        ]),
        actions: [
          if (unreadCount > 0)
            TextButton(onPressed: _markingAll ? null : _markAllRead, child: _markingAll ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('قراءة الكل')),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: body),
    );
  }
}
