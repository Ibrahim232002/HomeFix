import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/screens/notifications_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianDashboardRedesign extends StatelessWidget {
  const TechnicianDashboardRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final tech = state.currentTechProfile;
    final active = state.bookings.where((b) => b.status != BookingStatus.completed && b.status != BookingStatus.cancelled).toList();
    final avatarUrl = tech?.avatarUrl;
    final firstName = tech?.fullName.split(' ').first ?? state.currentUser?.fullName.split(' ').first ?? 'فني';
    final horizontalPadding = AppResponsive.pagePadding(context).left;
    final isAvailable = tech?.isAvailable ?? false;

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
                  padding: EdgeInsets.fromLTRB(horizontalPadding, AppDesignTokens.space5, horizontalPadding, AppDesignTokens.space3),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.technicianLight,
                          backgroundImage: avatarUrl?.isNotEmpty == true ? NetworkImage(avatarUrl!) : null,
                          child: avatarUrl?.isNotEmpty == true ? null : const Icon(Icons.person_rounded, color: AppColors.technicianDark),
                        ),
                        const SizedBox(width: AppDesignTokens.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('صباح الخير، $firstName', style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: AppDesignTokens.space1),
                              Text('ركّز على طلباتك الحالية وأنجز عملك بسهولة.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppDesignTokens.space2),
                  sliver: SliverToBoxAdapter(
                    child: HomeFixCard(
                      padding: const EdgeInsets.all(AppDesignTokens.space4),
                      borderColor: isAvailable ? AppColors.success.withOpacity(.35) : AppColors.border,
                      child: Row(
                        children: [
                          Icon(isAvailable ? Icons.radio_button_checked_rounded : Icons.pause_circle_outline_rounded, color: isAvailable ? AppColors.successDark : AppColors.textMuted),
                          const SizedBox(width: AppDesignTokens.space3),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isAvailable ? 'متاح لاستقبال الطلبات' : 'غير متاح حالياً', style: Theme.of(context).textTheme.titleMedium), Text(isAvailable ? 'يمكن للعملاء إرسال طلبات جديدة لك.' : 'فعّل التوفر عندما تكون جاهزاً للعمل.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted))])),
                          Switch(value: isAvailable, onChanged: (_) => state.toggleTechnicianAvailability()),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(padding: EdgeInsets.fromLTRB(horizontalPadding, AppDesignTokens.space5, horizontalPadding, AppDesignTokens.space2), sliver: SliverToBoxAdapter(child: Text('اليوم', style: Theme.of(context).textTheme.titleLarge))),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      HomeFixCard(child: _Metric(icon: Icons.near_me_rounded, label: 'طلبات متاحة', value: '${state.availableTechRequests.length}', color: AppColors.technicianPrimary)),
                      HomeFixCard(child: _Metric(icon: Icons.event_available_rounded, label: 'حجوزات نشطة', value: '${active.length}', color: AppColors.primary)),
                      HomeFixCard(child: _Metric(icon: Icons.account_balance_wallet_rounded, label: 'الرصيد', value: '${state.wallet?.currentBalance.toStringAsFixed(0) ?? '0'} ج.م', color: AppColors.successDark)),
                      HomeFixCard(child: _Metric(icon: Icons.star_rounded, label: 'التقييم', value: (tech?.rating ?? 0).toStringAsFixed(1), color: AppColors.warningDark)),
                    ]),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: AppResponsive.columns(context), crossAxisSpacing: AppDesignTokens.space3, mainAxisSpacing: AppDesignTokens.space3, childAspectRatio: 1.6),
                  ),
                ),
                SliverPadding(padding: EdgeInsets.fromLTRB(horizontalPadding, AppDesignTokens.space6, horizontalPadding, AppDesignTokens.space2), sliver: SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('طلبات جديدة', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () => state.setTechnicianNavIndex(1), child: const Text('عرض الكل'))]))),
                if (state.isLoading)
                  const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.space4), sliver: SliverToBoxAdapter(child: HomeFixSkeletonList(itemCount: 3)))
                else if (state.availableTechRequests.isEmpty)
                  const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.space4), sliver: SliverToBoxAdapter(child: HomeFixEmptyState(icon: Icons.inbox_outlined, title: 'لا توجد طلبات جديدة', message: 'ستظهر الطلبات المناسبة لك هنا عند توفرها.')))
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, AppDesignTokens.space6),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                      final request = state.availableTechRequests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDesignTokens.space2),
                        child: HomeFixCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(backgroundColor: AppColors.technicianLight, child: Icon(Icons.home_repair_service_rounded, color: AppColors.technicianDark)), title: Text(request.serviceNameAr, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(request.problemDescription, maxLines: 2, overflow: TextOverflow.ellipsis), trailing: HomeFixStatusChip(label: request.status.displayNameAr))),
                      );
                    }, childCount: state.availableTechRequests.length.clamp(0, 5))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Metric({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)), const SizedBox(width: AppDesignTokens.space2), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)), const SizedBox(height: AppDesignTokens.space1), Text(value, style: Theme.of(context).textTheme.titleMedium)]))]);
}
