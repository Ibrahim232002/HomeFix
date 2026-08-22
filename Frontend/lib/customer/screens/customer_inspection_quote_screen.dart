import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/inspection_model.dart';
import '../../models/service_quote_model.dart';
import '../../services/app_state_provider.dart';

class CustomerInspectionQuoteScreen extends StatefulWidget {
  final String requestId;

  const CustomerInspectionQuoteScreen({super.key, required this.requestId});

  @override
  State<CustomerInspectionQuoteScreen> createState() => _CustomerInspectionQuoteScreenState();
}

class _CustomerInspectionQuoteScreenState extends State<CustomerInspectionQuoteScreen> {
  bool _loading = true;
  String? _error;
  InspectionModel? _inspection;
  bool _actingQuote = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      final inspection = await provider.loadInspectionForRequest(widget.requestId);
      if (inspection != null && inspection.isCompleted) {
        await provider.loadServiceQuotes(int.parse(inspection.id));
      }
      if (!mounted) return;
      setState(() => _inspection = inspection);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorText(Object error) => error.toString().replaceFirst('Exception: ', '');

  Future<void> _acceptQuote(ServiceQuoteModel quote) async {
    final inspection = _inspection;
    if (inspection == null || _actingQuote) return;
    setState(() => _actingQuote = true);
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.acceptServiceQuote(quote.id, inspection.id);
      await provider.loadBookingForRequest(widget.requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول عرض السعر.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorText(error))),
      );
    } finally {
      if (mounted) setState(() => _actingQuote = false);
    }
  }

  Future<void> _rejectQuote(ServiceQuoteModel quote) async {
    final inspection = _inspection;
    if (inspection == null || _actingQuote) return;
    setState(() => _actingQuote = true);
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.rejectServiceQuote(quote.id, inspection.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض عرض السعر.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorText(error))),
      );
    } finally {
      if (mounted) setState(() => _actingQuote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final quotes = _inspection == null
        ? <ServiceQuoteModel>[]
        : provider.serviceQuotes.where((q) => q.inspectionId == _inspection!.id).toList()
      ..sort((a, b) => b.revision.compareTo(a.revision));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('المعاينة والتسعير #${widget.requestId}')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_inspection == null)
                          const _InfoCard(
                            title: 'لا توجد معاينة بعد',
                            message: 'لم يتم إنشاء معاينة مرتبطة بهذا الطلب حتى الآن.',
                            icon: Icons.assignment_late_outlined,
                          )
                        else ...[
                          _buildInspectionCard(_inspection!),
                          const SizedBox(height: 16),
                          if (_inspection!.isCompleted)
                            _buildQuotesCard(quotes)
                          else
                            const _InfoCard(
                              title: 'انتظار اكتمال المعاينة',
                              message: 'سيظهر عرض السعر بعد إتمام المعاينة وتسجيل نتائجها.',
                              icon: Icons.hourglass_top_rounded,
                            ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInspectionCard(InspectionModel inspection) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('حالة المعاينة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
              Chip(label: Text(inspection.status, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11))),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('رسوم المعاينة', '${inspection.fee.toStringAsFixed(2)} ج.م'),
          _detailRow('الموعد', inspection.scheduledAt),
          _detailRow('تاريخ الإنشاء', inspection.createdAt),
          if (inspection.completedAt != null) _detailRow('اكتملت في', inspection.completedAt!),
          if ((inspection.findings ?? '').isNotEmpty) ...[
            const Divider(height: 24),
            const Text('نتائج المعاينة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(inspection.findings!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuotesCard(List<ServiceQuoteModel> quotes) {
    if (quotes.isEmpty) {
      return const _InfoCard(
        title: 'لا يوجد عرض سعر بعد',
        message: 'سيظهر عرض السعر هنا فور إنشائه من الفني بعد اكتمال المعاينة.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('عروض السعر', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          ...quotes.map(_buildQuoteCard),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(ServiceQuoteModel quote) {
    final canAct = quote.isPendingCustomer && !quote.isExpiredByTime;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المراجعة #${quote.revision}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
              Text(quote.status, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${quote.amount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
          if ((quote.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(quote.notes!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, height: 1.4)),
          ],
          if (quote.expiresAt != null && quote.expiresAt!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('تنتهي الصلاحية: ${quote.expiresAt}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
          ],
          if (canAct) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _actingQuote ? null : () => _rejectQuote(quote), child: const Text('رفض', style: TextStyle(fontFamily: 'Cairo')))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: _actingQuote ? null : () => _acceptQuote(quote), child: Text(_actingQuote ? '...' : 'قبول العرض', style: const TextStyle(fontFamily: 'Cairo')))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
            Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700))),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _InfoCard({required this.title, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ])),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.errorDark)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo'))),
        ]),
      ),
    );
  }
}
