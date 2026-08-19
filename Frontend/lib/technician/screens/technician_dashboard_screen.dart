import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import '../../common/screens/notifications_screen.dart';
import 'technician_request_detail_screen.dart';

class TechnicianDashboardScreen extends StatelessWidget {
  const TechnicianDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final tech = appState.currentTechProfile;
    final isAvailable = tech?.isAvailable ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: (tech?.avatarUrl != null && tech!.avatarUrl!.isNotEmpty) ? NetworkImage(tech!.avatarUrl!) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tech?.fullName ?? (appState.currentUser?.fullName.isNotEmpty == true ? appState.currentUser!.fullName : 'الفني'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 16, color: AppColors.technicianPrimary),
                            ],
                          ),
                          Text(
                            tech != null && tech.specialties.isNotEmpty ? tech.specialties.join(' • ') : 'فني معتمد',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, size: 26),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAvailable ? AppColors.successLight : AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isAvailable ? AppColors.successDark.withOpacity(0.3) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: isAvailable ? AppColors.successDark : AppColors.textMuted, shape: BoxShape.circle),
                        child: Icon(isAvailable ? Icons.check_circle_rounded : Icons.pause_circle_filled_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAvailable ? 'أنت متصل ومتاح للطلبات الآن' : 'غير متصل (مستريح حالياً)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isAvailable ? AppColors.successDark : AppColors.textSecondary, fontFamily: 'Cairo'),
                            ),
                            Text(
                              isAvailable ? 'العملاء في منطقتك يمكنهم رؤيتك وإرسال الطلبات' : 'لن تستلم إشعارات طلبات جديدة أثناء عدم الاتصال',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                      ),
                      Switch(value: isAvailable, activeColor: AppColors.successDark, onChanged: (_) => appState.toggleTechnicianAvailability()),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(title: 'الرصيد المتاح للسحب', value: '${appState.wallet?.currentBalance.toInt() ?? 0} ج.م', icon: Icons.account_balance_wallet_rounded, color: AppColors.technicianPrimary, isPositive: true),
                  _buildStatCard(title: 'المهام المنجزة', value: '${tech?.completedJobsCount ?? 0}', icon: Icons.task_alt_rounded, color: AppColors.successDark),
                  _buildStatCard(title: 'التقييم العام', value: '${tech?.rating ?? 0.0} ⭐️', icon: Icons.star_rounded, color: const Color(0xFFF59E0B)),
                  _buildStatCard(title: 'إجمالي الأرباح الشهرية', value: '${appState.wallet?.totalEarnings.toInt() ?? 0} ج.م', icon: Icons.trending_up_rounded, color: AppColors.primary),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طلبات جديدة متاحة بالقرب منك (${appState.availableTechRequests.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                    TextButton(onPressed: () => appState.setTechnicianNavIndex(1), child: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.technicianPrimary))),
                  ],
                ),
              ),
            ),
            if (appState.availableTechRequests.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('لا توجد طلبات جديدة معلقة حالياً في منطقتك', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Cairo')))))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final req = appState.availableTechRequests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.technicianLight), boxShadow: [BoxShadow(color: AppColors.technicianPrimary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.technicianLight, borderRadius: BorderRadius.circular(8)), child: Text(req.categoryNameAr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.technicianPrimary, fontFamily: 'Cairo'))),
                                Text('#${req.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, fontFamily: 'Cairo')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(req.serviceNameAr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                            const SizedBox(height: 4),
                            Text(req.problemDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text('${req.address.city} - ${req.address.title}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                                const Spacer(),
                                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(req.preferredDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('نطاق السعر: ${req.estimatedPriceMin.toInt()} - ${req.estimatedPriceMax.toInt()} ج.م', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.technicianDark, fontFamily: 'Cairo')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.technicianPrimary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => TechnicianRequestDetailScreen(request: req)),
                                    );
                                  },
                                  child: const Text('تقديم عرض', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Cairo')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: appState.availableTechRequests.length.clamp(0, 3),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('جدول مواعيدك اليومية القادمة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')), TextButton(onPressed: () => appState.setTechnicianNavIndex(2), child: const Text('عرض الجدول', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.technicianPrimary)))]),
              ),
            ),
            if (appState.bookings.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('لا توجد حجوزات مجدولة حالياً', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Cairo')))))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = appState.bookings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.technicianLight, shape: BoxShape.circle), child: const Icon(Icons.handyman_rounded, color: AppColors.technicianPrimary, size: 20)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.serviceNameAr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text('العميل: ${booking.customerName} (${booking.scheduledTime})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo'))])),
                            StatusBadge.fromBookingStatus(booking.status),
                          ],
                        ),
                      );
                    },
                    childCount: appState.bookings.length.clamp(0, 3),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, bool isPositive = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo', fontWeight: FontWeight.w600)), Icon(icon, size: 18, color: color)]),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color, fontFamily: 'Cairo')),
      ]),
    );
  }
}
