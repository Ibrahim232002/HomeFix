import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/booking_model.dart';
import '../../models/inspection_model.dart';
import '../../models/service_quote_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianInspectionsScreen extends StatefulWidget {
  const TechnicianInspectionsScreen({super.key});

  @override
  State<TechnicianInspectionsScreen> createState() => _TechnicianInspectionsScreenState();
}

class _TechnicianInspectionsScreenState extends State<TechnicianInspectionsScreen> {
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      await Provider.of<AppStateProvider>(context, listen: false).loadTechnicianInspections();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorText(Object error) => error.toString().replaceFirst('Exception: ', '');

  Future<void> _createFromBooking(BookingModel booking) async {
    final scheduled = await _pickDateTime(context, initial: DateTime.now().add(const Duration(hours: 1)));
    if (scheduled == null || !mounted) return;
    try {
      setState(() => _busy.add('create-${booking.id}'));
      await Provider.of<AppStateProvider>(context, listen: false).createInspection(
        serviceRequestId: int.parse(booking.requestId),
        scheduledAt: scheduled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء المعاينة.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText(error))));
    } finally {
      if (mounted) setState(() => _busy.remove('create-${booking.id}'));
    }
  }

  Future<void> _reschedule(InspectionModel inspection) async {
    final current = DateTime.tryParse(inspection.scheduledAt) ?? DateTime.now();
    final scheduled = await _pickDateTime(context, initial: current);
    if (scheduled == null || !mounted) return;
    await _runInspectionAction(
      inspection,
      () => Provider.of<AppStateProvider>(context, listen: false).scheduleInspection(inspection.id, scheduled),
      'تم تحديث موعد المعاينة.',
    );
  }

  Future<void> _start(InspectionModel inspection) async {
    await _runInspectionAction(
      inspection,
      () => Provider.of<AppStateProvider>(context, listen: false).startInspection(inspection.id),
      'بدأت المعاينة.',
    );
  }

  Future<void> _cancel(InspectionModel inspection) async {
    await _runInspectionAction(
      inspection,
      () => Provider.of<AppStateProvider>(context, listen: false).cancelInspection(inspection.id),
      'تم إلغاء المعاينة.',
    );
  }

  Future<void> _noShow(InspectionModel inspection) async {
    await _runInspectionAction(
      inspection,
      () => Provider.of<AppStateProvider>(context, listen: false).noShowInspection(inspection.id),
      'تم تسجيل عدم الحضور.',
    );
  }

  Future<void> _complete(InspectionModel inspection) async {
    final controller = TextEditingController();
    final findings = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إكمال المعاينة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'نتائج المعاينة', hintText: 'اكتب الملاحظات والنتائج...', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('حفظ وإكمال', style: TextStyle(fontFamily: 'Cairo'))),
          ],
        ),
      ),
    );
    controller.dispose();
    if (findings == null || findings.isEmpty || !mounted) return;
    await _runInspectionAction(
      inspection,
      () => Provider.of<AppStateProvider>(context, listen: false).completeInspection(inspection.id, findings),
      'تم إكمال المعاينة.',
    );
  }

  Future<void> _runInspectionAction(InspectionModel inspection, Future<Object> Function() action, String success) async {
    if (_busy.contains(inspection.id)) return;
    setState(() => _busy.add(inspection.id));
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText(error))));
    } finally {
      if (mounted) setState(() => _busy.remove(inspection.id));
    }
  }

  Future<void> _quoteDialog({required InspectionModel inspection, ServiceQuoteModel? previous}) async {
    final amountController = TextEditingController(text: previous?.amount.toStringAsFixed(2) ?? '');
    final notesController = TextEditingController(text: previous?.notes ?? '');
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(previous == null ? 'عرض سعر جديد' : 'مراجعة عرض السعر', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'المبلغ', suffixText: 'ج.م', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(onPressed: () { final value = double.tryParse(amountController.text.trim()); if (value != null && value > 0) Navigator.pop(dialogContext, value); }, child: const Text('إرسال', style: TextStyle(fontFamily: 'Cairo'))),
          ],
        ),
      ),
    );
    final notes = notesController.text.trim();
    amountController.dispose();
    notesController.dispose();
    if (amount == null || !mounted) return;

    try {
      setState(() => _busy.add('quote-${inspection.id}'));
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      if (previous == null) {
        await provider.createServiceQuote(inspectionId: int.parse(inspection.id), amount: amount, notes: notes.isEmpty ? null : notes);
      } else {
        await provider.createQuoteRevision(quoteId: int.parse(previous.id), amount: amount, notes: notes.isEmpty ? null : notes);
      }
      await provider.loadServiceQuotes(int.parse(inspection.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال عرض السعر.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText(error))));
    } finally {
      if (mounted) setState(() => _busy.remove('quote-${inspection.id}'));
    }
  }

  Future<void> _showQuotes(InspectionModel inspection) async {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    try {
      await provider.loadServiceQuotes(int.parse(inspection.id));
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: _QuoteHistorySheet(inspection: inspection),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final inspections = provider.technicianInspections;
    final bookings = provider.bookings;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('المعاينات والتسعير')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.errorDark)), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')))])))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (bookings.isNotEmpty) ...[
                          const Text('إنشاء معاينة من حجز مؤكد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 10),
                          ...bookings.where((b) => b.status != BookingStatus.cancelled && b.status != BookingStatus.completed).map((booking) {
                            final busy = _busy.contains('create-${booking.id}');
                            return Card(
                              child: ListTile(
                                title: Text(booking.serviceNameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                                subtitle: Text('حجز #${booking.id} • ${booking.status.displayNameAr}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                                trailing: FilledButton(
                                  onPressed: busy ? null : () => _createFromBooking(booking),
                                  child: Text(busy ? '...' : 'إنشاء معاينة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                        ],
                        const Text('معايناتك', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 10),
                        if (inspections.isEmpty)
                          const EmptyStateWidget(icon: Icons.assignment_outlined, title: 'لا توجد معاينات', description: 'ستظهر هنا المعاينات المرتبطة بحجوزاتك.')
                        else
                          ...inspections.map(_buildInspectionCard),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInspectionCard(InspectionModel inspection) {
    final busy = _busy.contains(inspection.id) || _busy.contains('quote-${inspection.id}');
    final quotes = Provider.of<AppStateProvider>(context).serviceQuotes.where((q) => q.inspectionId == inspection.id).toList()
      ..sort((a, b) => b.revision.compareTo(a.revision));
    final latest = quotes.isEmpty ? null : quotes.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('معاينة #${inspection.id} • طلب #${inspection.serviceRequestId}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800))),
            Chip(label: Text(inspection.status, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10))),
          ]),
          const SizedBox(height: 6),
          Text('الموعد: ${inspection.scheduledAt}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
          if ((inspection.findings ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(inspection.findings!, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (inspection.status == 'Scheduled')
              OutlinedButton(onPressed: busy ? null : () => _start(inspection), child: const Text('بدء المعاينة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            if (inspection.status == 'Scheduled')
              OutlinedButton(onPressed: busy ? null : () => _reschedule(inspection), child: const Text('تغيير الموعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            if (inspection.status == 'Scheduled')
              TextButton(onPressed: busy ? null : () => _noShow(inspection), child: const Text('لم يحضر العميل', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            if (inspection.status == 'Scheduled' || inspection.status == 'InProgress')
              TextButton(onPressed: busy ? null : () => _cancel(inspection), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.error))),
            if (inspection.status == 'InProgress')
              ElevatedButton(onPressed: busy ? null : () => _complete(inspection), child: const Text('إكمال المعاينة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            if (inspection.status == 'Completed')
              OutlinedButton(onPressed: busy ? null : () => _showQuotes(inspection), child: const Text('سجل عروض السعر', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            if (inspection.status == 'Completed' && (latest == null || latest.status == 'Rejected' || latest.status == 'Expired'))
              ElevatedButton(onPressed: busy ? null : () => _quoteDialog(inspection: inspection, previous: latest), child: Text(latest == null ? 'إنشاء عرض سعر' : 'إضافة مراجعة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11))),
          ]),
        ]),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, {required DateTime initial}) async {
    final today = DateTime.now();
    final date = await showDatePicker(context: context, initialDate: initial.isBefore(today) ? today : initial, firstDate: today, lastDate: today.add(const Duration(days: 365)), builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!));
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial), builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _QuoteHistorySheet extends StatelessWidget {
  final InspectionModel inspection;

  const _QuoteHistorySheet({required this.inspection});

  @override
  Widget build(BuildContext context) {
    final quotes = Provider.of<AppStateProvider>(context).serviceQuotes.where((q) => q.inspectionId == inspection.id).toList()
      ..sort((a, b) => b.revision.compareTo(a.revision));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('سجل عروض السعر', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          if (quotes.isEmpty)
            const Text('لا توجد عروض سعر لهذه المعاينة.', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))
          else
            ...quotes.map((quote) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('مراجعة #${quote.revision} • ${quote.amount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                  subtitle: Text('${quote.status}${quote.notes == null || quote.notes!.isEmpty ? '' : ' • ${quote.notes}'}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                )),
        ]),
      ),
    );
  }
}
