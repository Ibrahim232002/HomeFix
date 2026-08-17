import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';
import '../../services/app_state_provider.dart';

class CustomerBookingScreen extends StatefulWidget {
  final String requestId;
  const CustomerBookingScreen({super.key, required this.requestId});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  final BookingRepository _repository = BookingRepository();
  BookingModel? _booking;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safeError(Object error) => error is ApiException ? error.message : 'تعذر تحميل الحجز. يرجى المحاولة مرة أخرى.';

  Future<void> _load() async {
    if (_loading) {
      // Initial load is already in progress; avoid duplicate requests.
    }
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final booking = await _repository.getBookingByRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _booking = booking);
    } catch (e) {
      if (mounted) setState(() => _error = _safeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  HomeFixStatusTone _tone(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return HomeFixStatusTone.info;
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
        return HomeFixStatusTone.technician;
      case BookingStatus.awaitingCompletion:
        return HomeFixStatusTone.warning;
      case BookingStatus.completed:
        return HomeFixStatusTone.success;
      case BookingStatus.cancelled:
        return HomeFixStatusTone.error;
    }
  }

  int _currentTimelineIndex(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return 0;
      case BookingStatus.arrived:
        return 1;
      case BookingStatus.inProgress:
        return 2;
      case BookingStatus.awaitingCompletion:
        return 3;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return 4;
    }
  }

  Future<void> _verifyCompletion() async {
    final booking = _booking;
    if (booking == null || _busy) return;
    final codeController = TextEditingController();
    var codeIssued = false;
    var dialogBusy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('تأكيد إتمام الخدمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(codeIssued ? 'أدخل رمز الإتمام الذي وصلك.' : 'أرسل رمز الإتمام ثم أدخله لتأكيد انتهاء الخدمة.'),
              if (codeIssued) ...[
                const SizedBox(height: AppDesignTokens.space3),
                TextField(
                  controller: codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'رمز التحقق'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: dialogBusy ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            HomeFixButton(
              expanded: false,
              loading: dialogBusy,
              label: codeIssued ? 'تأكيد الإتمام' : 'إرسال الرمز',
              onPressed: () async {
                setDialogState(() => dialogBusy = true);
                try {
                  if (!codeIssued) {
                    await context.read<AppStateProvider>().requestVerificationCode(booking.id, 'JobCompletion');
                    if (dialogContext.mounted) setDialogState(() => codeIssued = true);
                  } else {
                    if (mounted) setState(() => _busy = true);
                    await context.read<AppStateProvider>().verifyBookingCode(booking.id, 'JobCompletion', codeController.text.trim());
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    await _load();
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(_safeError(e))));
                  }
                } finally {
                  if (dialogContext.mounted) setDialogState(() => dialogBusy = false);
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
          ],
        ),
      ),
    );
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الحجز')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(padding: padding, children: const [HomeFixSkeletonList(itemCount: 5)])
            : _error != null
                ? ListView(
                    padding: padding,
                    children: [
                      SizedBox(height: 360, child: HomeFixErrorState(title: 'تعذر تحميل الحجز', message: _error, onRetry: _load)),
                    ],
                  )
                : booking == null
                    ? ListView(
                        children: const [
                          SizedBox(height: 220),
                          HomeFixEmptyState(icon: Icons.event_busy_outlined, title: 'لا يوجد حجز بعد', message: 'سيظهر الحجز هنا بعد قبول عرض الفني.'),
                        ],
                      )
                    : ListView(
                        padding: padding.add(const EdgeInsets.only(bottom: 32)),
                        children: [
                          AppResponsive.content(
                            context,
                            child: HomeFixCard(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryDark, AppColors.primary],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderColor: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('حجز الخدمة', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                                  const SizedBox(height: AppDesignTokens.space2),
                                  Text('#${booking.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: AppDesignTokens.space4),
                                  HomeFixStatusChip(label: booking.status.displayNameAr, tone: _tone(booking.status), icon: Icons.circle),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDesignTokens.space4),
                          AppResponsive.content(context, child: _timeline(context, booking)),
                          const SizedBox(height: AppDesignTokens.space4),
                          AppResponsive.content(context, child: HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('تفاصيل الخدمة', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppDesignTokens.space3),
                            _InfoRow(icon: Icons.build_outlined, label: 'الخدمة', value: booking.serviceNameAr.isEmpty ? 'غير محدد' : booking.serviceNameAr),
                            _InfoRow(icon: Icons.person_outline, label: 'الفني', value: booking.technicianName.isEmpty ? 'غير محدد' : booking.technicianName),
                            _InfoRow(icon: Icons.location_on_outlined, label: 'العنوان', value: booking.address.fullAddressDescription),
                            _InfoRow(icon: Icons.schedule_outlined, label: 'الموعد', value: booking.scheduledTime.isEmpty ? booking.scheduledDate : '${booking.scheduledDate} · ${booking.scheduledTime}'),
                            _InfoRow(icon: Icons.payments_outlined, label: 'السعر', value: '${booking.price.toStringAsFixed(2)} ج.م'),
                          ]))),
                          const SizedBox(height: AppDesignTokens.space4),
                          if (booking.status == BookingStatus.awaitingCompletion)
                            AppResponsive.content(
                              context,
                              child: HomeFixButton(label: 'تأكيد إتمام الخدمة', icon: Icons.verified_outlined, loading: _busy, onPressed: _verifyCompletion),
                            ),
                        ],
                      ),
      ),
    );
  }

  Widget _timeline(BuildContext context, BookingModel booking) {
    final labels = ['مؤكدة', 'الفني وصل', 'جاري العمل', 'بانتظار التأكيد', 'مكتملة'];
    final current = _currentTimelineIndex(booking.status);
    return HomeFixCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('رحلة الحجز', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDesignTokens.space4),
        ...List.generate(labels.length, (index) {
          final done = booking.status != BookingStatus.cancelled && index <= current;
          final active = booking.status != BookingStatus.cancelled && index == current;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: done ? AppColors.primary : AppColors.borderLight, shape: BoxShape.circle), child: Icon(done ? Icons.check_rounded : Icons.circle_outlined, size: 17, color: done ? Colors.white : AppColors.textMuted)),
              if (index != labels.length - 1) Container(width: 2, height: 32, color: index < current ? AppColors.primary : AppColors.borderLight),
            ]),
            const SizedBox(width: AppDesignTokens.space3),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 5, bottom: 10), child: Text(labels[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: active ? FontWeight.w800 : FontWeight.w500)))),
          ]);
        }),
        if (booking.status == BookingStatus.cancelled)
          const HomeFixSuccessBanner(message: 'هذا الحجز ملغى ولا توجد إجراءات إضافية مطلوبة.'),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDesignTokens.space3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 19, color: AppColors.textMuted),
          const SizedBox(width: AppDesignTokens.space2),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ]),
      );
}
