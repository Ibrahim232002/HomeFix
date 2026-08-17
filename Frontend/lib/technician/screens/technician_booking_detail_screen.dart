import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;
  const TechnicianBookingDetailScreen({super.key, required this.booking});

  @override
  State<TechnicianBookingDetailScreen> createState() => _TechnicianBookingDetailScreenState();
}

class _TechnicianBookingDetailScreenState extends State<TechnicianBookingDetailScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _transition(BookingStatus next) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await context.read<AppStateProvider>().updateBookingStatus(widget.booking.id, next);
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _verifyStart() async {
    final code = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد بدء العمل'),
        content: TextField(controller: code, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رمز التحقق الذي استلمه العميل')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, code.text.trim()), child: const Text('تأكيد'))],
      ),
    );
    code.dispose();
    if (value == null || value.isEmpty) return;
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await context.read<AppStateProvider>().verifyBookingCode(widget.booking.id, 'JobStart', value);
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppStateProvider>().refreshAuthenticatedData(),
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          children: [
            AppResponsive.content(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              HomeFixCard(child: Row(children: [Expanded(child: Text(b.serviceNameAr.isEmpty ? 'الحجز' : b.serviceNameAr, style: Theme.of(context).textTheme.headlineSmall)), HomeFixStatusChip(label: b.status.displayNameAr, tone: HomeFixStatusTone.technician)])),
              const SizedBox(height: AppDesignTokens.space3),
              HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('الموعد والموقع', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDesignTokens.space2),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: Text(b.scheduledDate), subtitle: Text(b.scheduledTime)),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on_outlined), title: const Text('عنوان العميل'), subtitle: Text(b.address.fullAddressDescription)),
              ])),
              const SizedBox(height: AppDesignTokens.space3),
              HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('القيمة', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDesignTokens.space2),
                Text('${b.price.toStringAsFixed(2)} ج.م', style: Theme.of(context).textTheme.headlineSmall),
                if (b.notes?.isNotEmpty == true) ...[const SizedBox(height: AppDesignTokens.space2), Text(b.notes!)],
              ])),
              if (_error != null) ...[const SizedBox(height: AppDesignTokens.space3), Text(_error!, style: const TextStyle(color: AppColors.errorDark))],
              const SizedBox(height: AppDesignTokens.space4),
              if (b.status == BookingStatus.upcoming) HomeFixButton(expanded: true, loading: _busy, label: 'وصلت إلى الموقع', icon: Icons.location_on_rounded, onPressed: () => _transition(BookingStatus.arrived)),
              if (b.status == BookingStatus.arrived) HomeFixButton(expanded: true, loading: _busy, label: 'تأكيد بدء العمل', icon: Icons.play_arrow_rounded, onPressed: _verifyStart),
              if (b.status == BookingStatus.inProgress) HomeFixButton(expanded: true, loading: _busy, label: 'إنهاء العمل وطلب تأكيد العميل', icon: Icons.check_circle_outline_rounded, onPressed: () => _transition(BookingStatus.awaitingCompletion)),
              if (b.status == BookingStatus.awaitingCompletion) HomeFixCard(child: Text('تم إنهاء العمل. بانتظار تأكيد العميل لإكمال الحجز.', style: Theme.of(context).textTheme.bodyLarge)),
            ])),
          ],
        ),
      ),
    );
  }
}
