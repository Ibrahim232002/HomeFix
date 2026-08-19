import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/auth_repository.dart';
import 'customer_addresses_screen.dart';
import '../../common/screens/notifications_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, AppStateProvider appState) async {
    // AuthRepository always clears local tokens even when the server token is
    // already revoked/expired. The server failure is intentionally swallowed
    // there so logout remains safe and idempotent for the user.
    await AuthRepository().logout();
    appState.logout();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) ? NetworkImage(user!.avatarUrl!) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                  const SizedBox(height: 4),
                  Text(user?.phoneNumber ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
                    child: const Text('عميل مميز ⭐️', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  _buildMenuItem(context, icon: Icons.location_on_outlined, title: 'عناويني المحفوظة', subtitle: '${appState.savedAddresses.length} عناوين مضافة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()))),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(context, icon: Icons.notifications_none_rounded, title: 'الإشعارات والتنبيهات', subtitle: '${appState.notifications.length} إشعار', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(context, icon: Icons.credit_card_rounded, title: 'طرق الدفع والبطاقات', subtitle: 'الدفع النقدي متاح حالياً، والدفع الإلكتروني غير متاح بعد', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الدفع الإلكتروني غير متاح في عقد الـAPI الحالي. الدفع النقدي متاح من تفاصيل الطلب.')))),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(context, icon: Icons.language_rounded, title: 'لغة التطبيق', subtitle: 'العربية (الافتراضية)', onTap: () {}),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(context, icon: Icons.headset_mic_outlined, title: 'مركز المساعدة وخدمة العملاء', subtitle: 'تواصل معنا على مدار الساعة', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فريق الدعم الفني في خدمتك دائماً')))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                title: 'تسجيل الخروج',
                titleColor: AppColors.error,
                onTap: () => _logout(context, appState),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor ?? AppColors.textPrimary, fontFamily: 'Cairo')),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')) : null,
      trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
    );
  }
}
