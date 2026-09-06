import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_state_provider.dart';

class ReviewDialog extends StatefulWidget {
  final String requestId;
  final String technicianId;
  final String technicianName;
  final String serviceNameAr;

  const ReviewDialog({
    Key? key,
    required this.requestId,
    required this.technicianId,
    required this.technicianName,
    required this.serviceNameAr,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 5.0;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await Provider.of<AppStateProvider>(context, listen: false).submitReview(
        requestId: widget.requestId,
        technicianId: widget.technicianId,
        rating: _rating,
        comment: _commentController.text,
        serviceNameAr: widget.serviceNameAr,
      );

      if (!mounted) return;
      Navigator.pop(context);
      messenger?.showSnackBar(
        const SnackBar(content: Text('شكراً لتقييمك! تم حفظ التقييم بنجاح.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تقييم ${widget.technicianName}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'طلب خدمة: ${widget.serviceNameAr}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 32,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() => _rating = starIndex.toDouble());
                          },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'رأيك وملاحظاتك عن الفني',
                  hintText: 'كيف كانت تجربة الصيانة والتعامل؟',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'إرسال التقييم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
