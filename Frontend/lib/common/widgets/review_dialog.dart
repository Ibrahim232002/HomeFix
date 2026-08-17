import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../repositories/review_repository.dart';
import '../../services/app_state_provider.dart';

class ReviewDialog extends StatefulWidget {
  final String requestId;
  final String technicianId;
  final String technicianName;
  final String serviceNameAr;

  const ReviewDialog({super.key, required this.requestId, required this.technicianId, required this.technicianName, required this.serviceNameAr});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final ReviewRepository _repository = ReviewRepository();
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  bool _alreadyReviewed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingReview() async {
    final requestId = int.tryParse(widget.requestId);
    if (requestId == null) {
      if (mounted) setState(() { _loading = false; _error = 'بيانات التقييم غير صالحة.'; });
      return;
    }
    try {
      await _repository.getReviewByRequest(requestId);
      if (mounted) setState(() { _alreadyReviewed = true; _loading = false; });
    } on NotFoundException {
      if (mounted) setState(() { _alreadyReviewed = false; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e is ApiException ? e.message : 'تعذر التحقق من حالة التقييم.'; });
    }
  }

  Future<void> _submit() async {
    if (_submitting || _alreadyReviewed || _rating < 1 || _rating > 5) return;
    setState(() { _submitting = true; _error = null; });
    try {
      await context.read<AppStateProvider>().submitReview(requestId: widget.requestId, technicianId: widget.technicianId, rating: _rating, comment: _commentController.text.trim(), serviceNameAr: widget.serviceNameAr);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() { _submitting = false; _error = e is ApiException ? e.message : 'تعذر إرسال التقييم. يرجى المحاولة مرة أخرى.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تقييم الخدمة'),
        content: SizedBox(
          width: 420,
          child: _loading
              ? const HomeFixLoadingList(itemCount: 3)
              : _error != null && !_alreadyReviewed
                  ? HomeFixErrorState(title: 'تعذر تحميل التقييم', message: _error, onRetry: _checkExistingReview)
                  : _alreadyReviewed
                      ? const HomeFixEmptyState(icon: Icons.rate_review_outlined, title: 'تم تقييم هذه الخدمة', message: 'لا يمكن إرسال تقييم آخر لهذا الطلب.')
                      : AppResponsive.content(
                          context,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(widget.serviceNameAr, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppDesignTokens.space1),
                              Text('تقييم الفني ${widget.technicianName}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            ])),
                            const SizedBox(height: AppDesignTokens.space4),
                            Text('اختر تقييماً من 1 إلى 5', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: AppDesignTokens.space2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final selected = index + 1 <= _rating;
                                return Semantics(
                                  button: true,
                                  label: 'تقييم ${index + 1} من 5',
                                  child: IconButton(
                                    tooltip: '${index + 1}',
                                    icon: Icon(selected ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.warning, size: 34),
                                    onPressed: _submitting ? null : () => setState(() => _rating = (index + 1).toDouble()),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: AppDesignTokens.space3),
                            TextField(controller: _commentController, enabled: !_submitting, maxLines: 4, textInputAction: TextInputAction.newline, decoration: const InputDecoration(labelText: 'ملاحظتك (اختياري)', hintText: 'ما الذي أعجبك أو يحتاج إلى تحسين؟')),
                            if (_error != null) ...[
                              const SizedBox(height: AppDesignTokens.space2),
                              Text(_error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.errorDark)),
                            ],
                          ]),
                        ),
        ),
        actions: _loading || _alreadyReviewed
            ? [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]
            : [
                TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: const Text('إلغاء')),
                HomeFixButton(expanded: false, loading: _submitting, label: 'إرسال التقييم', icon: Icons.send_rounded, onPressed: _submit),
              ],
      ),
    );
  }
}
