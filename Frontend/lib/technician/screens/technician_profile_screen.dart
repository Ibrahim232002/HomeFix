import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../common/screens/notifications_screen.dart';
import '../../common/screens/support_center_screen.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';
import 'technician_availability_screen.dart';
import 'technician_documents_screen.dart';
import 'technician_service_areas_screen.dart';
import 'technician_settings_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});
  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final ITechnicianRepository _repo = TechnicianRepository();
  TechnicianProfileDto? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  int? get _userId => int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _userId;
    if (id == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await _repo.getApiTechnicianProfileByUserId(id);
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _toggleAvailability() async {
    final profile = _profile;
    if (profile == null || _saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _repo.updateApiTechnicianProfile(profile.id, UpdateTechnicianProfileRequest(isAvailable: !profile.isAvailable));
      if (mounted) setState(() { _profile = updated; _saving = false; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الملف المهني'), actions: [IconButton(tooltip: 'الإعدادات', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianSettingsScreen())), icon: const Icon(Icons.settings_outlined))]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppResponsive.content(context, child: _loading
                ? const HomeFixLoadingList(itemCount: 4)
                : _error != null
                    ? HomeFixErrorState(title: 'تعذر تحميل الملف المهني', message: _error, onRetry: _load)
                    : _profile == null
                        ? const HomeFixEmptyState(icon: Icons.engineering_outlined, title: 'الملف غير متاح', message: 'لا يوجد ملف مهني مرتبط بهذا الحساب.')
                        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            HomeFixCard(child: Column(children: [
                              CircleAvatar(radius: 42, backgroundImage: _profile!.profileImageUrl?.isNotEmpty == true ? NetworkImage(_profile!.profileImageUrl!) : null, child: _profile!.profileImageUrl?.isNotEmpty == true ? null : const Icon(Icons.engineering_rounded, size: 42)),
                              const SizedBox(height: AppDesignTokens.space3),
                              Text(session.user?.fullName ?? 'الفني', style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text(session.user?.email ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              const SizedBox(height: AppDesignTokens.space3),
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [HomeFixStatusChip(label: _profile!.isVerified ? 'تم التحقق' : 'قيد التحقق', tone: _profile!.isVerified ? HomeFixStatusTone.success : HomeFixStatusTone.warning), const SizedBox(width: 8), Text('${_profile!.averageRating.toStringAsFixed(1)} ★ • ${_profile!.totalJobs} عمل')]),
                              const SizedBox(height: AppDesignTokens.space3),
                              Text(_profile!.bio?.isNotEmpty == true ? _profile!.bio! : 'لا توجد نبذة مهنية مضافة.'),
                              const SizedBox(height: AppDesignTokens.space3),
                              FilledButton.icon(onPressed: _saving ? null : _toggleAvailability, icon: Icon(_profile!.isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline), label: Text(_profile!.isAvailable ? 'تعطيل استقبال الطلبات' : 'تفعيل استقبال الطلبات')),
                            ])),
                            const SizedBox(height: AppDesignTokens.space3),
                            HomeFixCard(child: Column(children: [
                              _LinkTile(icon: Icons.schedule_outlined, title: 'أوقات التوفر', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianAvailabilityScreen()))),
                              const Divider(height: 1),
                              _LinkTile(icon: Icons.location_city_outlined, title: 'مناطق الخدمة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianServiceAreasScreen()))),
                              const Divider(height: 1),
                              _LinkTile(icon: Icons.badge_outlined, title: 'الوثائق', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianDocumentsScreen()))),
                              const Divider(height: 1),
                              _LinkTile(icon: Icons.notifications_none_rounded, title: 'الإشعارات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                              const Divider(height: 1),
                              _LinkTile(icon: Icons.support_agent_rounded, title: 'الدعم', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterScreen()))),
                            ])),
                            const SizedBox(height: AppDesignTokens.space4),
                            TextButton.icon(onPressed: session.isRefreshing ? null : session.logout, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
                          ]),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.title, required this.onTap});
  @override Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_left_rounded), onTap: onTap);
}
