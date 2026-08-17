import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import 'technician_availability_screen.dart';
import 'technician_documents_screen.dart';
import 'technician_service_areas_screen.dart';

class TechnicianSettingsScreen extends StatelessWidget {
  const TechnicianSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: AppResponsive.pagePadding(context),
        children: [
          AppResponsive.content(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeFixCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(session.user?.fullName ?? 'الفني'),
                    subtitle: Text(session.user?.email ?? ''),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space3),
                HomeFixCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: const Text('أوقات التوفر'),
                        subtitle: const Text('حدد الفترات التي تستقبل فيها الحجوزات'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TechnicianAvailabilityScreen(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_city_outlined),
                        title: const Text('مناطق الخدمة'),
                        subtitle: const Text('إدارة المدن التي تغطيها'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TechnicianServiceAreasScreen(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('الوثائق'),
                        subtitle: const Text('متابعة حالة مستندات الاعتماد'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TechnicianDocumentsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space4),
                HomeFixCard(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: session.isRefreshing ? null : session.logout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
