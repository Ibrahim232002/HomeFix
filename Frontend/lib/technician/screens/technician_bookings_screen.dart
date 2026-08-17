import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianBookingsScreen extends StatefulWidget {
  const TechnicianBookingsScreen({super.key});

  @override
  State<TechnicianBookingsScreen> createState() => _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends State<TechnicianBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final Set<String> _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<BookingModel> _filter(List<BookingModel> all, int index) {
    switch (index) {
      case 0:
        return all.where((b) => b.status == BookingStatus.upcoming || b.status == BookingStatus.arrived).toList();
      case 1:
        return all.where((b) => b.status == BookingStatus.inProgress || b.status == BookingStatus.awaitingCompletion).toList();
      case 2:
        return all.where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.cancelled).toList();
      default:
        return all;
    }
  }

  String _safeError(Object error) => error is ApiException ? error.message : 'تعذر تحديث الحجز. يرجى المحاولة مرة أخرى.';

  Future<void> _transition(BuildContext context, BookingModel booking, BookingStatus next) async {
    if (_busy.contains(booking.id)) return;
    setState(() => _busy.add(booking.id));
    try {
      await context.read<AppStateProvider>().updateBookingStatus(booking.id, next);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث حالة الحجز إلى ${next.displayNameAr}.')),
        );
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_safeError(e))));
    } finally {
      if (mounted) setState(() => _busy.remove(booking.id));
    }
  }

  Future<void> _issueAndVerifyStart(BuildContext context, BookingModel booking) async {
    final codeController = TextEditingController();
    var busy = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تأكيد بدء العمل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('سيتم إرسال رمز التحقق إلى بريدك الإلكتروني المرتبط بالحساب.'),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'رمز التحقق'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      setDialogState(() => busy = true);
                      try {
                        await context.read<AppStateProvider>().requestVerificationCode(booking.id, 'JobStart');
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم إرسال رمز التحقق.')));
                        }
                      } catch (e) {
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(_safeError(e))));
                      } finally {
                        if (dialogContext.mounted) setDialogState(() => busy = false);
                      }
                    },
              child: const Text('إرسال الرمز'),
            ),
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (codeController.text.trim().isEmpty) return;
                      setDialogState(() => busy = true);
                      try {
                        await context.read<AppStateProvider>().verifyBookingCode(booking.id, 'JobStart', codeController.text.trim());
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(_safeError(e))));
                      } finally {
                        if (dialogContext.mounted) setDialogState(() => busy = false);
                      }
                    },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<AppStateProvider>().bookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الحجوزات'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'التنفيذ'),
            Tab(text: 'المكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: List.generate(3, (index) {
          final list = _filter(bookings, index);
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_busy_outlined,
              title: 'لا توجد حجوزات',
              description: 'ستظهر الحجوزات بعد قبول العميل لأحد عروضك.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final booking = list[i];
              final busy = _busy.contains(booking.id);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('حجز #${booking.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          StatusBadge.fromBookingStatus(booking.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(booking.serviceNameAr.isEmpty ? 'الخدمة المرتبطة بالطلب' : booking.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      if (booking.customerName.isNotEmpty) Text('العميل: ${booking.customerName}'),
                      const SizedBox(height: 8),
                      Text('الموعد: ${booking.scheduledDate} ${booking.scheduledTime}'.trim()),
                      const SizedBox(height: 8),
                      Text('السعر: ${booking.price.toStringAsFixed(2)} ج.م'),
                      const SizedBox(height: 12),
                      if (booking.status == BookingStatus.upcoming)
                        ElevatedButton(
                          onPressed: busy ? null : () => _transition(context, booking, BookingStatus.arrived),
                          child: busy ? const CircularProgressIndicator() : const Text('وصلت إلى الموقع'),
                        ),
                      if (booking.status == BookingStatus.arrived)
                        ElevatedButton(
                          onPressed: busy ? null : () => _issueAndVerifyStart(context, booking),
                          child: const Text('تأكيد بدء العمل'),
                        ),
                      if (booking.status == BookingStatus.inProgress)
                        ElevatedButton(
                          onPressed: busy ? null : () => _transition(context, booking, BookingStatus.awaitingCompletion),
                          child: const Text('إنهاء أعمال الفني وطلب تأكيد العميل'),
                        ),
                      if (booking.status == BookingStatus.awaitingCompletion)
                        const Text(
                          'بانتظار تأكيد العميل لإكمال الحجز.',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
