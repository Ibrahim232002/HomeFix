import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/api_dtos.dart';
import '../../repositories/customer_profile_repository.dart';
import '../../services/app_state_provider.dart';
import '../../common/screens/notifications_screen.dart';
import '../../common/screens/support_center_screen.dart';
import 'customer_addresses_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

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
    if (userId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _repository.getProfileByUserId(userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
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

  Future<void> _editProfileImage() async {
    final controller = TextEditingController(text: _profile?.profileImageUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رابط صورة الملف الشخصي'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('حفظ')),
        ],
      ),
    );
    controller.dispose();
    if (url == null || _profile == null) return;

    setState(() => _saving = true);
    try {
      final updated = await _repository.updateProfile(
        _profile!.id,
        UpdateCustomerProfileRequest(profileImageUrl: url.isEmpty ? null : url),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Card(
                color: AppColors.errorLight,
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.errorDark),
                  title: Text(_error!),
                  trailing: TextButton(onPressed: _loadProfile, child: const Text('إعادة المحاولة')),
                ),
              ),
            if (_loading)
              const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))
            else if (_profile == null)
              const SizedBox(height: 260, child: EmptyStateWidget(icon: Icons.person_outline, title: 'تعذر تحميل الملف الشخصي', description: 'تحقق من الاتصال ثم حاول مرة أخرى.'))
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundImage: _profile!.profileImageUrl?.isNotEmpty == true
                                ? NetworkImage(_profile!.profileImageUrl!)
                                : null,
                            child: _profile!.profileImageUrl?.isNotEmpty == true ? null : const Icon(Icons.person, size: 42),
                          ),
                          IconButton.filled(
                            onPressed: _saving ? null : _editProfileImage,
                            icon: const Icon(Icons.edit, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(session.user?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(session.user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('الاسم والبريد الإلكتروني يديرهما نظام الحساب الحالي. تحديث صورة الملف الشخصي متاح من الخادم.', style: TextStyle(fontSize: 11, color: AppColors.textMuted), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _menu(context, Icons.location_on_outlined, 'عناويني المحفوظة', '${appState.savedAddresses.length} عناوين', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()))),
                    const Divider(height: 1),
                    _menu(context, Icons.notifications_none_rounded, 'الإشعارات', '${appState.unreadNotificationsCount} غير مقروء', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    const Divider(height: 1),
                    _menu(context, Icons.support_agent, 'الدعم الفني', 'فتح ومتابعة تذاكر الدعم', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterScreen()))),
                    const Divider(height: 1),
                    _menu(context, Icons.payments_outlined, 'الدفع', 'الدفع النقدي مدعوم حالياً', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بوابة الدفع الإلكتروني غير متاحة حالياً في عقد الـAPI')))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  onTap: () => session.logout(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    );
  }
}
