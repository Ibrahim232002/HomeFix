import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';

class BookingVerificationDialog extends StatefulWidget {
  final String title;
  final String description;
  final Future<BookingModel> Function(String code) onVerify;
  final Future<BookingVerificationIssueResult> Function() onResend;

  const BookingVerificationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<BookingVerificationDialog> createState() => _BookingVerificationDialogState();
}

class _BookingVerificationDialogState extends State<BookingVerificationDialog> {
  final _controller = TextEditingController();
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  Future<void> _verify() async {
    if (_verifying || _resending) return;
    final code = _controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'أدخل رمز التحقق المكون من 6 أرقام.');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await widget.onVerify(code);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_verifying || _resending) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final result = await widget.onResend();
      if (!mounted) return;
      if (result.developmentCode != null && result.developmentCode!.isNotEmpty) {
        setState(() => _error = 'رمز التطوير: ${result.developmentCode}');
      }
    } catch (error) {
      if (mounted) setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.description, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_verifying && !_resending,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: const InputDecoration(
              counterText: '',
              hintText: '••••••',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: _verifying || _resending ? null : _resend,
            child: Text(
              _resending ? 'جاري إعادة الإرسال...' : 'إعادة إرسال الرمز',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _verifying || _resending ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          onPressed: _verifying || _resending ? null : _verify,
          child: _verifying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo')),
        ),
      ],
    );
  }
}
