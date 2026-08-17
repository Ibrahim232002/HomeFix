import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../services/app_state_provider.dart';
import 'create_request_screen.dart';
import 'service_detail_screen.dart';
import 'customer_request_detail_screen.dart';
import '../../common/screens/notifications_screen.dart';

class CustomerHomeRedesign extends StatelessWidget {
  const CustomerHomeRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;
    final active = state.customerRequests.where((r) => r.status != ServiceRequestStatus.completed && r.status != ServiceRequestStatus.cancelled).toList();
    final upcoming = state.bookings.where((b) => b.status != BookingStatus.completed && b.status != BookingStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppResponsive.content(
          context,
          child: RefreshIndicator(
            onRefresh: state.refreshAuthenticatedData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppDesignTokens.pagePadding, 20, AppDesignTokens.pagePadding, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('أهلاً ${user?.fullName.split(' ').first ?? 'بك'} 👋', style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text('ماذا تحتاج في منزلك اليوم؟', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Badge(
                          isLabelVisible: state.unreadNotificationsCount > 0,
                          label: Text('${state.unreadNotificationsCount}'),
                          child: IconButton.filledTonal(
                            tooltip: 'الإشعارات',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                            icon: const Icon(Icons.notifications_none_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: HomeFixCard(
                      padding: const EdgeInsets.all(AppDesignTokens.space5),
                      gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('احتياجك يبدأ بخطوة واحدة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                                SizedBox(height: 6),
                                Text('اختر خدمة، حدّد العنوان، واترك الباقي علينا.', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: state.services.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRequestScreen(initialService: state.services.first))),
                            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
                            child: const Text('اطلب خدمة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (active.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppDesignTokens.pagePadding, 20, AppDesignTokens.pagePadding, 4),
                    sliver: SliverToBoxAdapter(child: Text('طلبك الحالي', style: Theme.of(context).textTheme.titleLarge)),
                  ),
                if (active.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding, vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: HomeFixCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primaryDark)),
                          title: Text(active.first.serviceNameAr, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(active.first.problemDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_left_rounded),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerRequestDetailScreen(request: active.first))),
                        ),
                      ),
                    ),
                  )
                else if (upcoming.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding, vertical: 12),
                    sliver: SliverToBoxAdapter(child: HomeFixEmptyState(icon: Icons.home_work_outlined, title: 'لا توجد أعمال جارية', message: 'ابدأ بطلب خدمة وسنساعدك في كل خطوة.')),
                  ),
                if (upcoming.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppDesignTokens.pagePadding, 18, AppDesignTokens.pagePadding, 4),
                    sliver: SliverToBoxAdapter(child: Text('الحجز القادم', style: Theme.of(context).textTheme.titleLarge)),
                  ),
                if (upcoming.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding, vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: HomeFixCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: AppColors.technicianLight, child: const Icon(Icons.calendar_today_rounded, color: AppColors.technicianDark)),
                          title: Text(upcoming.first.serviceName, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('${upcoming.first.scheduledDate} • ${upcoming.first.scheduledTime ?? 'موعد قريب'}'),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppDesignTokens.pagePadding, 20, AppDesignTokens.pagePadding, 8),
                  sliver: SliverToBoxAdapter(child: Text('الخدمات', style: Theme.of(context).textTheme.titleLarge)),
                ),
                if (state.isLoadingPublic && state.services.isEmpty)
                  const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding), sliver: SliverToBoxAdapter(child: HomeFixSkeletonList(itemCount: 3)))
                else if (!state.isLoadingPublic && state.services.isEmpty)
                  const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.pagePadding), sliver: SliverToBoxAdapter(child: HomeFixEmptyState(icon: Icons.home_repair_service_outlined, title: 'الخدمات غير متاحة الآن', message: 'حاول مرة أخرى خلال قليل.', showRetry: false)))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppDesignTokens.pagePadding, 0, AppDesignTokens.pagePadding, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final service = state.services[index];
                        return HomeFixCard(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 88, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)), child: const Center(child: Icon(Icons.home_repair_service_rounded, size: 36, color: AppColors.primary))),
                              const SizedBox(height: 12),
                              Text(service.nameAr, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(service.categoryNameAr, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        );
                      }, childCount: state.services.length.clamp(0, 6)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: AppResponsive.columns(context), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.95),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
