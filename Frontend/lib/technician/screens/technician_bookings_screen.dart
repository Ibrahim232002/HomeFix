import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import '../../common/screens/chat_detail_screen.dart';

class TechnicianBookingsScreen extends StatefulWidget {
  const TechnicianBookingsScreen({Key? key}) : super(key: key);

  @override
  State<TechnicianBookingsScreen> createState() => _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends State<TechnicianBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterBookings(List<BookingModel> all, int index) {
    switch (index) {
      case 0: // Upcoming
        return all.where((b) => b.status == BookingStatus.upcoming).toList();
      case 1: // In progress
        return all.where((b) => b.status == BookingStatus.inProgress).toList();
      case 2: // Completed
        return all.where((b) => b.status == BookingStatus.completed).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جدول المواعيد والحجوزات'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.technicianPrimary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.technicianPrimary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'قيد التنفيذ'),
            Tab(text: 'المكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (tabIndex) {
          final bookings = _filterBookings(appState.bookings, tabIndex);

          if (bookings.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_busy_rounded,
              title: 'لا توجد حجوزات في هذا التبويب',
              description: 'يمكنك قبول طلبات صيانة جديدة من قائمة الطلبات المتاحة لتعبئة جدولك.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حجز #${b.id}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                          ),
                          StatusBadge.fromBookingStatus(b.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        b.serviceNameAr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العميل: ${b.customerName}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                      ),
                      const SizedBox(height: 12),

                      // Schedule & Address Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.technicianPrimary),
                                const SizedBox(width: 6),
                                Text(
                                  'الموعد: ${b.scheduledDate} (${b.scheduledTime})',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.technicianPrimary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${b.address.city} - ${b.address.fullAddressDescription}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ: ${b.price.toInt()} ج.م',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.technicianDark, fontFamily: 'Cairo'),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.technicianPrimary),
                                onPressed: () {
                                  appState.setTechnicianNavIndex(0); // or start conversation
                                },
                              ),
                              if (b.status == BookingStatus.upcoming) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.technicianPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    appState.updateBookingStatus(b.id, BookingStatus.inProgress);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم بدء تنفيذ المهمة!')),
                                    );
                                  },
                                  child: const Text('بدء العمل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                ),
                              ] else if (b.status == BookingStatus.inProgress) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.successDark,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    appState.updateBookingStatus(b.id, BookingStatus.completed);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إنهاء المهمة وإيداع الأجر في المحفظة!')),
                                    );
                                  },
                                  child: const Text('إنهاء المهمة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
