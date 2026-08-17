import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import 'technician_booking_detail_screen.dart';

class TechnicianBookingsScreen extends StatefulWidget {
  const TechnicianBookingsScreen({super.key});

  @override
  State<TechnicianBookingsScreen> createState() => _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends State<TechnicianBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppStateProvider>().refreshAuthenticatedData();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<BookingModel> _filter(List<BookingModel> all, int index) {
    if (index == 0) {
      return all
          .where(
            (b) =>
                b.status == BookingStatus.upcoming ||
                b.status == BookingStatus.arrived,
          )
          .toList();
    }
    if (index == 1) {
      return all
          .where(
            (b) =>
                b.status == BookingStatus.inProgress ||
                b.status == BookingStatus.awaitingCompletion,
          )
          .toList();
    }
    return all
        .where(
          (b) =>
              b.status == BookingStatus.completed ||
              b.status == BookingStatus.cancelled,
        )
        .toList();
  }

  HomeFixStatusTone _tone(BookingStatus status) {
    if (status == BookingStatus.completed) return HomeFixStatusTone.success;
    if (status == BookingStatus.cancelled) return HomeFixStatusTone.error;
    if (status == BookingStatus.inProgress ||
        status == BookingStatus.awaitingCompletion) {
      return HomeFixStatusTone.info;
    }
    return HomeFixStatusTone.technician;
  }

  Widget _tabBody(BuildContext context, List<BookingModel> bookings, int index) {
    final items = _filter(bookings, index);
    if (_loading) return const HomeFixLoadingList(itemCount: 3);
    if (_error != null) {
      return HomeFixErrorState(
        title: 'تعذر تحميل الحجوزات',
        message: _error,
        onRetry: _load,
      );
    }
    if (items.isEmpty) {
      return const HomeFixEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'لا توجد حجوزات',
        message: 'ستظهر الحجوزات بعد قبول العميل لأحد عروضك.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: AppResponsive.pagePadding(context),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ...items.map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: AppDesignTokens.space3),
              child: HomeFixCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianBookingDetailScreen(booking: booking),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceNameAr.isEmpty
                                ? 'حجز #${booking.id}'
                                : booking.serviceNameAr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        HomeFixStatusChip(
                          label: booking.status.displayNameAr,
                          tone: _tone(booking.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.space2),
                    Text(
                      'العميل: ${booking.customerName.isEmpty ? 'غير متاح في الاستجابة' : booking.customerName}',
                    ),
                    const SizedBox(height: 4),
                    Text('${booking.scheduledDate} • ${booking.scheduledTime}'),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.price.toStringAsFixed(2)} ج.م',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<AppStateProvider>().bookings;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'جاري العمل'),
            Tab(text: 'السجل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _tabBody(context, bookings, 0),
          _tabBody(context, bookings, 1),
          _tabBody(context, bookings, 2),
        ],
      ),
    );
  }
}
