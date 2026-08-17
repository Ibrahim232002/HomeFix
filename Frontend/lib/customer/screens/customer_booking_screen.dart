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
    setState(() { _loading = true; _error = null; });
    try {
      final booking = await _repository.getBookingByRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _booking = booking);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
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
              Text(codeIssued ? 'أدخل رمز التحقق الذي وصلك على بريدك الإلكتروني.' : 'اضغط إرسال الرمز للحصول على رمز تأكيد إتمام الخدمة.'),
              if (codeIssued) ...[
                const SizedBox(height: 12),
                TextField(controller: codeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رمز التحقق')),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: dialogBusy ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            TextButton(
              onPressed: dialogBusy ? null : () async {
                setDialogState(() => dialogBusy = true);
                try {
                  if (!codeIssued) {
                    await context.read<AppStateProvider>().requestVerificationCode(booking.id, 'JobCompletion');
                    if (dialogContext.mounted) setDialogState(() => codeIssued = true);
                  } else {
                    setState(() => _busy = true);
                    await context.read<AppStateProvider>().verifyBookingCode(booking.id, 'JobCompletion', codeController.text.trim());
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    await _load();
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
                  }
                } finally {
                  setDialogState(() => dialogBusy = false);
                  if (mounted) setState(() => _busy = false);
                }
              },
              child: Text(codeIssued ? 'تأكيد الإتمام' : 'إرسال الرمز'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(children: const [SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))])
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Card(child: ListTile(title: Text(_error!), trailing: TextButton(onPressed: _load, child: const Text('إعادة المحاولة')))))])
                : booking == null
                    ? ListView(children: const [SizedBox(height: 180), Center(child: Text('لا يوجد حجز مرتبط بهذا الطلب حتى الآن.'))])
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(child: ListTile(title: Text('حجز #${booking.id}'), subtitle: Text(booking.status.displayNameAr))),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(booking.serviceNameAr, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 8),
                                  Text('العميل: ${booking.customerName}'),
                                  Text('السعر: ${booking.price.toStringAsFixed(2)} ج.م'),
                                  if (booking.notes?.isNotEmpty == true) Text(booking.notes!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (booking.status == BookingStatus.awaitingCompletion)
                            ElevatedButton.icon(
                              onPressed: _busy ? null : _verifyCompletion,
                              icon: const Icon(Icons.verified_outlined),
                              label: const Text('تأكيد إتمام الخدمة'),
                            ),
                        ],
                      ),
      ),
    );
  }
}
