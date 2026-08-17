import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../common/screens/notifications_screen.dart';
import '../../common/screens/support_center_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';
import 'technician_availability_screen.dart';
import 'technician_documents_screen.dart';
import 'technician_offers_screen.dart';
import 'technician_service_areas_screen.dart';
import 'technician_settings_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final ITechnicianRepository _repository = TechnicianRepository();

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
    final userId = _userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذر تحديد حساب الفني الحالي.';
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _repository.getApiTechnicianProfileByUserId(userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _toggleAvailability() async {
    final profile = _profile;
    if (profile == null || _saving) return;

    setState(() => _saving = true);

    try {
      final updated = await _repository.updateApiTechnicianProfile(
        profile.id,
        UpdateTechnicianProfileRequest(isAvailable: !profile.isAvailable),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف المهني'),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianSettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppResponsive.content(
              context,
              child: _buildContent(context, session),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthSessionProvider session) {
    if (_loading) return const HomeFixLoadingList(itemCount: 4);

    if (_error != null) {
      return HomeFixErrorState(
        title: 'تعذر تحميل الملف المهني',
        message: _error,
        onRetry: _load,
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const HomeFixEmptyState(
        icon: Icons.engineering_outlined,
        title: 'الملف غير متاح',
        message: 'لا يوجد ملف مهني مرتبط بهذا الحساب.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TechnicianProfileSummary(
          profile: profile,
          displayName: session.user?.fullName ?? 'الفني',
          email: session.user?.email ?? '',
          saving: _saving,
          onToggleAvailability: _toggleAvailability,
        ),
        const SizedBox(height: AppDesignTokens.space3),
        const _TechnicianProfileLinks(),
        const SizedBox(height: AppDesignTokens.space4),
        HomeFixButton(
          variant: HomeFixButtonVariant.text,
          icon: Icons.logout,
          label: 'تسجيل الخروج',
          expanded: false,
          onPressed: session.isRefreshing ? null : session.logout,
        ),
      ],
    );
  }
}

class _TechnicianProfileSummary extends StatelessWidget {
  const _TechnicianProfileSummary({
    required this.profile,
    required this.displayName,
    required this.email,
    required this.saving,
    required this.onToggleAvailability,
  });

  final TechnicianProfileDto profile;
  final String displayName;
  final String email;
  final bool saving;
  final VoidCallback onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    final hasImage = profile.profileImageUrl?.isNotEmpty == true;

    return HomeFixCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundImage: hasImage ? NetworkImage(profile.profileImageUrl!) : null,
            child: hasImage ? null : const Icon(Icons.engineering_rounded, size: 42),
          ),
          const SizedBox(height: AppDesignTokens.space3),
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignTokens.space1),
          Text(
            email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignTokens.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HomeFixStatusChip(
                label: profile.isVerified ? 'تم التحقق' : 'قيد التحقق',
                tone: profile.isVerified
                    ? HomeFixStatusTone.success
                    : HomeFixStatusTone.warning,
              ),
              const SizedBox(width: AppDesignTokens.space2),
              Text(
                '${profile.averageRating.toStringAsFixed(1)} ★ • ${profile.totalJobs} عمل',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space3),
          Text(
            profile.bio?.isNotEmpty == true
                ? profile.bio!
                : 'لا توجد نبذة مهنية مضافة.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignTokens.space3),
          HomeFixButton(
            loading: saving,
            icon: profile.isAvailable
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            label: profile.isAvailable
                ? 'تعطيل استقبال الطلبات'
                : 'تفعيل استقبال الطلبات',
            onPressed: onToggleAvailability,
          ),
        ],
      ),
    );
  }
}

class _TechnicianProfileLinks extends StatelessWidget {
  const _TechnicianProfileLinks();

  @override
  Widget build(BuildContext context) {
    return HomeFixCard(
      child: Column(
        children: [
          _LinkTile(
            icon: Icons.local_offer_outlined,
            title: 'عروضي',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianOffersScreen()),
            ),
          ),
          const Divider(height: 1),
          _LinkTile(
            icon: Icons.schedule_outlined,
            title: 'أوقات التوفر',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianAvailabilityScreen()),
            ),
          ),
          const Divider(height: 1),
          _LinkTile(
            icon: Icons.location_city_outlined,
            title: 'مناطق الخدمة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianServiceAreasScreen()),
            ),
          ),
          const Divider(height: 1),
          _LinkTile(
            icon: Icons.badge_outlined,
            title: 'الوثائق',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianDocumentsScreen()),
            ),
          ),
          const Divider(height: 1),
          _LinkTile(
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const Divider(height: 1),
          _LinkTile(
            icon: Icons.support_agent_rounded,
            title: 'الدعم',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportCenterScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    );
  }
}
