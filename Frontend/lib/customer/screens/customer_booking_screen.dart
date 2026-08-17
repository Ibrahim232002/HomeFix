import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final booking = await _repository.getBookingByRequest(int.parse(widget.requestId));
      if (!mounted) return;
      setState(() => _booking = booking);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تأكيد إتمام الخدمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(codeIssued
                  ? 'أدخل رمز التحقق الذي وصلك على بريدك الإلكتروني.'
                  : 'اضغط إرسال الرمز للحصول على رمز تأكيد إتمام الخدمة.'),
              if (codeIssued) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رمز التحقق'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: dialogBusy ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            TextButton(
              onPressed: dialogBusy
                  ? null
                  : () async {
                      setDialogState(() => dialogBusy = true);
                      try {
                        await context.read<AppStateProvider>().requestVerificationCode(booking.id, 'JobCompletion');
                        if (dialogContext.mounted) {
                          setDialogState(() => codeIssued = true);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم إرسال الرمز.')));
                        }
                      } catch (e) {
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        if (dialogContext.mounted) setDialogState(() => dialogBusy = false);
                      }
                    },
              child: const Text('إرسال الرمز'),
            ),
            if (codeIssued)
              ElevatedButton(
                onPressed: dialogBusy || codeController.text.trim().isEmpty
                    ? null
                    : () async {
                        setDialogState(() => dialogBusy = true);
                        try {
                          await context.read<AppStateProvider>().verifyBookingCode(booking.id, 'JobCompletion', codeController.text.trim());
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          if (mounted) await _load();
                        } catch (e) {
                          if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          if (dialogContext.mounted) setDialogState(() => dialogBusy = false);
                        }
                      },
                child: const Text('تأكيد الإتمام'),
              ),
          ],
        ),
      ),
    );
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الحجز')),
        body: Center(child: Text(_error!)),
      );
    }
    final booking = _booking;
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الحجز')),
        body: const Center(child: Text('لا يوجد حجز مرتبط بهذا الطلب بعد.')),
      );
    }

    final canConfirm = booking.status == BookingStatus.awaitingCompletion;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('الحجز #${booking.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(booking.serviceNameAr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('الحالة: ${booking.status.displayNameAr}'),
                  const SizedBox(height: 8),
                  Text('السعر: ${booking.price.toStringAsFixed(2)} ج.م'),
                  const SizedBox(height: 8),
                  Text('الفني: ${booking.technicianName}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (canConfirm)
            ElevatedButton(
              onPressed: _busy ? null : _verifyCompletion,
              child: const Text('تأكيد إتمام الخدمة'),
            )
          else
            const Text(
              'يمكن تأكيد الإتمام بعد أن ينهي الفني العمل ويصبح الحجز في حالة انتظار تأكيد العميل.',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
