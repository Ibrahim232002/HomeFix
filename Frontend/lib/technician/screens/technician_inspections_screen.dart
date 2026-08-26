import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/inspection_model.dart';
import '../../models/offer_model.dart';
import '../../models/service_quote_model.dart';
import '../../repositories/service_request_offer_repository.dart';
import '../../services/app_state_provider.dart';

class TechnicianInspectionsScreen extends StatefulWidget {
  final String? requestId;

  const TechnicianInspectionsScreen({super.key, this.requestId});

  @override
  State<TechnicianInspectionsScreen> createState() => _TechnicianInspectionsScreenState();
}

class _TechnicianInspectionsScreenState extends State<TechnicianInspectionsScreen> {
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};
  List<ServiceRequestOfferModel> _acceptedInspectionOffers = [];

  final ServiceRequestOfferRepository _offerRepository = ServiceRequestOfferRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.loadTechnicianInspections();
      final offers = await _offerRepository.getMyOffers();
      final existingRequestIds = provider.technicianInspections.map((item) => item.serviceRequestId.toString()).toSet();
      _acceptedInspectionOffers = offers.where((offer) =>
          (widget.requestId == null || offer.serviceRequestId == widget.requestId) &&
          offer.status.toLowerCase() == 'accepted' &&
          offer.pricingMode == 2 &&
          !existingRequestIds.contains(offer.serviceRequestId)).toList();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorText(Object error) => error.toString().replaceFirst('Exception: ', '');

  Future<void> _createFromOffer(ServiceRequestOfferModel offer) async {
    final scheduled = await _pickDateTime(context, initial: DateTime.now().add(const Duration(hours: 1)));
    if (scheduled == null || !mounted) return;
    final requestId = int.tryParse(offer.serviceRequestId);
    if (requestId == null || requestId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('معرف طلب الخدمة غير صالح.')));
      return;
    }

    try {
      setState(() => _busy.add('create-${offer.id}'));
      await Provider.of<AppStateProvider>(context, listen: false).createInspection(
        serviceRequestId: requestId,
        scheduledAt: scheduled,
      );
      _acceptedInspectionOffers.removeWhere((item) => item.id == offer.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء المعاينة.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText(error))));
    } finally {
      if (mounted) setState(() => _busy.remove('create-${offer.id}'));
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
    final findings = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _InspectionCompletionDialog(),
    );
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
    final result = await showDialog<_QuoteDialogResult>(
      context: context,
      builder: (dialogContext) => _ServiceQuoteDialog(previous: previous),
    );
    if (result == null || !mounted) return;

    try {
      setState(() => _busy.add('quote-${inspection.id}'));
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      if (previous == null) {
        await provider.createServiceQuote(inspectionId: int.parse(inspection.id), amount: result.amount, notes: result.notes.isEmpty ? null : result.notes);
      } else {
        await provider.createQuoteRevision(quoteId: int.parse(previous.id), amount: result.amount, notes: result.notes.isEmpty ? null : result.notes);
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
    final inspections = widget.requestId == null
        ? provider.technicianInspections
        : provider.technicianInspections
            .where((item) => item.serviceRequestId == widget.requestId)
            .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.requestId == null
              ? 'المعاينات والتسعير'
              : 'معاينة الطلب #'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.errorDark)), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')))])))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_acceptedInspectionOffers.isNotEmpty) ...[
                          const Text('طلبات المعاينة المقبولة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 10),
                          ..._acceptedInspectionOffers.map((offer) {
                            final service = provider.services.cast<dynamic>().where((item) => item.id == offer.serviceId).cast<dynamic>().fold<dynamic>(null, (current, item) => current ?? item);
                            final serviceName = service?.nameAr?.toString() ?? 'طلب خدمة #${offer.serviceRequestId}';
                            final busy = _busy.contains('create-${offer.id}');
                            return Card(
                              child: ListTile(
                                title: Text(serviceName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                                subtitle: Text('طلب #${offer.serviceRequestId} • العرض المقبول ${offer.proposedPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                                trailing: FilledButton(
                                  onPressed: busy ? null : () => _createFromOffer(offer),
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
                          const EmptyStateWidget(icon: Icons.fact_check_outlined, title: 'لا توجد معاينات', description: 'بعد قبول عرض المعاينة، يمكنك إنشاء الموعد هنا.')
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

class _InspectionCompletionDialog extends StatefulWidget {
  const _InspectionCompletionDialog();

  @override
  State<_InspectionCompletionDialog> createState() => _InspectionCompletionDialogState();
}

class _InspectionCompletionDialogState extends State<_InspectionCompletionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إكمال المعاينة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نتائج المعاينة', hintText: 'اكتب الملاحظات والنتائج...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('حفظ وإكمال', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _QuoteDialogResult {
  final double amount;
  final String notes;

  const _QuoteDialogResult({required this.amount, required this.notes});
}

class _ServiceQuoteDialog extends StatefulWidget {
  final ServiceQuoteModel? previous;

  const _ServiceQuoteDialog({this.previous});

  @override
  State<_ServiceQuoteDialog> createState() => _ServiceQuoteDialogState();
}

class _ServiceQuoteDialogState extends State<_ServiceQuoteDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.previous?.amount.toStringAsFixed(2) ?? '');
    _notesController = TextEditingController(text: widget.previous?.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(widget.previous == null ? 'عرض سعر جديد' : 'مراجعة عرض السعر', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'المبلغ', suffixText: 'ج.م', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(_amountController.text.trim());
              if (value != null && value > 0) {
                Navigator.pop(
                  context,
                  _QuoteDialogResult(amount: value, notes: _notesController.text.trim()),
                );
              }
            },
            child: const Text('إرسال', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
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
