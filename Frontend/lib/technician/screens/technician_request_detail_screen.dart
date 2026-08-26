import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_state_provider.dart';
import '../../models/service_request_model.dart';
import 'technician_inspections_screen.dart';

class TechnicianRequestDetailScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const TechnicianRequestDetailScreen({Key? key, required this.request}) : super(key: key);

  @override
  State<TechnicianRequestDetailScreen> createState() => _TechnicianRequestDetailScreenState();
}

class _TechnicianRequestDetailScreenState extends State<TechnicianRequestDetailScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل سعراً صحيحاً للعرض.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await Provider.of<AppStateProvider>(context, listen: false).submitTechnicianOffer(
        request: widget.request,
        proposedPrice: price,
        technicianNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تقديم العرض بنجاح.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final inspectionEnabled = provider.services.any(
      (service) => service.id == widget.request.serviceId && service.pricingMode == 2,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('طلب #${widget.request.id}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.technicianLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.request.serviceNameAr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    Text(widget.request.problemDescription, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.5)),
                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 17, color: AppColors.technicianPrimary),
                      const SizedBox(width: 5),
                      Expanded(child: Text('${widget.request.address.city} - ${widget.request.address.street} (${widget.request.address.building})', style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'))),
                    ]),
                    const SizedBox(height: 7),
                    Row(children: [
                      const Icon(Icons.schedule_rounded, size: 17, color: AppColors.technicianPrimary),
                      const SizedBox(width: 5),
                      Text('${widget.request.preferredDate} (${widget.request.preferredTime})', style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                    ]),
                    const SizedBox(height: 12),
                    Text('رسوم الزيارة: ${widget.request.visitFee?.toInt() ?? 'غير متاحة'} ج.م', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.technicianDark, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              if (inspectionEnabled) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianInspectionsScreen(
                        requestId: widget.request.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.fact_check_rounded, size: 18),
                  label: const Text(
                    'متابعة المعاينة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تقديم عرضك للعميل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'السعر المقترح (ج.م)', hintText: 'مثال: 450'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'ملاحظة للفني/العميل (اختياري)', hintText: 'اكتب تفاصيل مختصرة عن العرض أو ما يشمله السعر.'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.technicianPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      onPressed: _submitting ? null : _submitOffer,
                      icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.local_offer_outlined),
                      label: const Text('تقديم عرض', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
