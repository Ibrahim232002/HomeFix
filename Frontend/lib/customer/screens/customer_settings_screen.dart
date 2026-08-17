import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../common/screens/chat_list_screen.dart';
import '../../common/screens/notifications_screen.dart';
import '../../common/screens/support_center_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import 'customer_addresses_screen.dart';

class CustomerSettingsScreen extends StatelessWidget {
  const CustomerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          children: [
            AppResponsive.content(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('إدارة الحساب', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('خيارات مرتبطة بالخدمات التي يدعمها التطبيق والـAPI الحالي.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  HomeFixCard(
                    child: Column(
                      children: [
                        _item(context, Icons.notifications_none_rounded, 'الإشعارات', 'عرض الإشعارات وإدارتها', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                        const Divider(height: 1),
                        _item(context, Icons.location_on_outlined, 'العناوين', 'إضافة وتعديل وحذف العناوين المحفوظة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()))),
                        const Divider(height: 1),
                        _item(context, Icons.support_agent_rounded, 'الدعم', 'إنشاء ومتابعة تذاكر الدعم والرسائل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterScreen()))),
                        const Divider(height: 1),
                        _item(context, Icons.chat_bubble_outline_rounded, 'المحادثات', 'محادثاتك الحالية مع الفنيين', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  HomeFixCard(
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: AppColors.primarySurface, child: Icon(Icons.verified_user_outlined, color: AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الجلسة الحالية', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(session.isAuthenticated ? 'الحساب متصل ومصادق عليه.' : 'الجلسة غير متاحة.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const HomeFixEmptyState(
                    icon: Icons.tune_rounded,
                    title: 'لا توجد إعدادات إضافية مدعومة حالياً',
                    message: 'لا نعرض خيارات محلية توحي بوجود إعدادات غير موجودة في عقد الـAPI.',
                  ),
                  const SizedBox(height: 8),
                  HomeFixButton(
                    variant: HomeFixButtonVariant.destructive,
                    icon: Icons.logout_rounded,
                    label: 'تسجيل الخروج',
                    onPressed: () async {
                      await session.logout();
                      if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      minVerticalPadding: 10,
      leading: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: AppColors.primary)),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    );
  }
}
