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
import '../../models/api_dtos.dart';
import '../../repositories/customer_profile_repository.dart';
import '../../services/app_state_provider.dart';
import 'customer_addresses_screen.dart';
import 'customer_settings_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ICustomerProfileRepository _repository = CustomerProfileRepository();
  CustomerProfileDto? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');
    if (userId == null) {
      if (mounted) setState(() { _loading = false; _error = 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await _repository.getProfileByUserId(userId);
      if (!mounted) return;
      setState(() { _profile = profile; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _editProfileImage() async {
    final controller = TextEditingController(text: _profile?.profileImageUrl ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحديث صورة الملف الشخصي'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'رابط الصورة', hintText: 'https://...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('حفظ')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || _profile == null || _saving) return;

    setState(() => _saving = true);
    try {
      final updated = await _repository.updateProfile(
        _profile!.id,
        UpdateCustomerProfileRequest(profileImageUrl: value.isEmpty ? null : value),
      );
      if (!mounted) return;
      setState(() { _profile = updated; _saving = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الملف الشخصي.')));
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSettingsScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppResponsive.pagePadding(context),
            children: [
              AppResponsive.content(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading)
                      const HomeFixLoadingList(itemCount: 4)
                    else if (_error != null && _profile == null)
                      HomeFixErrorState(title: 'تعذر تحميل الملف الشخصي', message: _error, onRetry: _loadProfile)
                    else if (_profile == null)
                      const HomeFixEmptyState(icon: Icons.person_outline_rounded, title: 'لا يوجد ملف شخصي', message: 'سيظهر ملفك الشخصي هنا بعد اكتمال إعداد الحساب.')
                    else ...[
                      HomeFixCard(
                        gradient: AppColors.primaryGradient,
                        borderColor: Colors.transparent,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                                  backgroundImage: _profile!.profileImageUrl?.isNotEmpty == true ? NetworkImage(_profile!.profileImageUrl!) : null,
                                  child: _profile!.profileImageUrl?.isNotEmpty == true ? null : const Icon(Icons.person_rounded, size: 44, color: Colors.white),
                                ),
                                IconButton.filled(
                                  tooltip: 'تعديل الصورة',
                                  onPressed: _saving ? null : _editProfileImage,
                                  style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(session.user?.fullName ?? 'المستخدم', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(session.user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Text('الاسم والبريد الإلكتروني يتبعان الحساب المصادق عليه. يمكن تحديث صورة الملف الشخصي من الخادم.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      HomeFixCard(
                        child: Column(
                          children: [
                            _menu(context, Icons.location_on_outlined, 'عناويني', '${appState.savedAddresses.length} عنوان محفوظ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()))),
                            const Divider(height: 1),
                            _menu(context, Icons.notifications_none_rounded, 'الإشعارات', '${appState.unreadNotificationsCount} غير مقروء', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                            const Divider(height: 1),
                            _menu(context, Icons.chat_bubble_outline_rounded, 'المحادثات', 'تابع محادثاتك مع الفنيين', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()))),
                            const Divider(height: 1),
                            _menu(context, Icons.support_agent_rounded, 'الدعم الفني', 'التذاكر والرسائل مع فريق الدعم', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterScreen()))),
                            const Divider(height: 1),
                            _menu(context, Icons.settings_outlined, 'الإعدادات', 'الحساب والجلسة والتنبيهات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSettingsScreen()))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      HomeFixCard(
                        backgroundColor: AppColors.errorLight,
                        borderColor: AppColors.error.withValues(alpha: 0.18),
                        child: HomeFixButton(
                          variant: HomeFixButtonVariant.destructive,
                          icon: Icons.logout_rounded,
                          label: 'تسجيل الخروج',
                          onPressed: _saving ? null : () async {
                            await session.logout();
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      minVerticalPadding: 10,
      leading: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: AppColors.primary, size: 20)),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    );
  }
}
