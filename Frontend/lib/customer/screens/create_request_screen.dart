import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/service_model.dart';
import '../../models/address_model.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_request_detail_screen.dart';

class CreateRequestScreen extends StatefulWidget {
  final ServiceModel initialService;

  const CreateRequestScreen({Key? key, required this.initialService}) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  late ServiceModel _selectedService;
  AddressModel? _selectedAddress;
  final TextEditingController _problemController = TextEditingController();

  String _selectedDate = 'اليوم';
  String _selectedTime = '04:30 مساءً';
  final List<ServiceRequestFileModel> _attachedFiles = [];
  bool _isSubmitting = false;

  final List<String> _quickDates = [
    'اليوم',
    'غداً',
    'بعد غد',
  ];

  final List<String> _quickTimes = [
    '09:00 صباحاً',
    '11:30 صباحاً',
    '02:00 ظهراً',
    '04:30 مساءً',
    '07:00 مساءً',
    '09:00 مساءً',
  ];

  final List<String> _quickTags = [
    'تسريب ماء مفاجئ',
    'المكيف يصدر صوتاً عالياً',
    'ضعف في التبريد',
    'ماس كهربائي وفصل القاطع',
    'بحاجة لتنظيف عميق',
    'تثبيت وتركيب جديد',
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
    final state = Provider.of<AppStateProvider>(context, listen: false);
    if (state.savedAddresses.isNotEmpty) {
      _selectedAddress = state.savedAddresses.first;
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    final double visitFee = _selectedService.pricing.visitFee;
    final double estimatedMin = _selectedService.pricing.minPrice;
    final double estimatedMax = _selectedService.pricing.maxPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلب خدمة صيانة جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedService.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.build, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedService.categoryNameAr,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo'),
                        ),
                        Text(
                          _selectedService.nameAr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                        ),
                        Text(
                          'التكلفة: ${estimatedMin.toInt()} - ${estimatedMax.toInt()} ${_selectedService.pricing.currency}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
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
                    children: const [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'عنوان تقديم الخدمة',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (appState.savedAddresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'لم يتم إضافة أي عنوان بعد. يرجى إضافة عنوان أولاً لتنفيذ الخدمة.',
                              style: TextStyle(fontSize: 12, fontFamily: 'Cairo', color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<AddressModel>(
                      value: _selectedAddress,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: appState.savedAddresses.map((addr) {
                        return DropdownMenuItem(
                          value: addr,
                          child: Text(
                            '${addr.title} (${addr.city})',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedAddress = val);
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'وصف المشكلة أو العطل بالتفصيل',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اختر عبارة جاهزة أو اكتب وصفاً مخصصاً لمساعدة الفني في إحضار القطع المناسبة:',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _quickTags.map((tag) {
                      return ActionChip(
                        label: Text(tag, style: const TextStyle(fontSize: 11, fontFamily: 'Cairo')),
                        backgroundColor: AppColors.scaffoldBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                        onPressed: () {
                          if (_problemController.text.isEmpty) {
                            _problemController.text = tag;
                          } else {
                            _problemController.text += '، $tag';
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _problemController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'اكتب هنا تفاصيل إضافية عن العطل، عدد الوحدات، أي ملاحظات للفني...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 38),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                    label: const Text('إرفاق صور أو مقطع للعطل (غير متاح حالياً)', style: TextStyle(fontSize: 12, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    onPressed: null,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'رفع الملفات غير متاح لأن الخادم الحالي لا يوفّر endpoint لرفع الملفات الثنائية. لن يتم حفظ مرفق وهمي.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الموعد المفضل لزيارة الفني',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 10),
                  const Text('اختر اليوم:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickDates.map((date) {
                        final isSel = _selectedDate == date;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(date, style: TextStyle(fontSize: 12, fontFamily: 'Cairo', fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppColors.primaryLight,
                            onSelected: (_) => setState(() => _selectedDate = date),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('اختر التوقيت:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickTimes.map((time) {
                      final isSel = _selectedTime == time;
                      return ChoiceChip(
                        label: Text(time, style: TextStyle(fontSize: 11, fontFamily: 'Cairo', fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        selectedColor: AppColors.primaryLight,
                        onSelected: (_) => setState(() => _selectedTime = time),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التسعير',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 10),
                  _buildPriceRow('رسوم الزيارة والفحص', '${visitFee.toInt()} ${_selectedService.pricing.currency}'),
                  const SizedBox(height: 6),
                  _buildPriceRow('أجور الخدمة التقديرية', '${(estimatedMin - visitFee).toInt()} - ${(estimatedMax - visitFee).toInt()} ${_selectedService.pricing.currency}'),
                  const Divider(height: 16),
                  const Text(
                    'المبلغ المعروض هنا تقديري فقط. السعر النهائي وعروض الفني والخصم المعتمد تأتي من الخادم.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_selectedAddress == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إضافة عنوان لتنفيذ الخدمة أولاً'),
                          ),
                        );
                        return;
                      }

                      if (_problemController.text.trim().isEmpty) {
                        _problemController.text = 'طلب خدمة ${_selectedService.nameAr}';
                      }

                      setState(() => _isSubmitting = true);
                      try {
                        final newReq = await appState.createServiceRequest(
                          service: _selectedService,
                          address: _selectedAddress!,
                          problemDescription: _problemController.text.trim(),
                          preferredDate: _selectedDate,
                          preferredTime: _selectedTime,
                          files: _attachedFiles,
                        );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.successDark,
                            content: Text('تم إرسال طلبك #${newReq.id} بنجاح وجاري إسناده لأقرب فني معتمد!'),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerRequestDetailScreen(requestId: newReq.id),
                          ),
                        );
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر إرسال الطلب. يرجى المحاولة مرة أخرى.')),
                        );
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'تأكيد وإرسال طلب الصيانة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDiscount ? AppColors.successDark : AppColors.textSecondary, fontFamily: 'Cairo')),
        Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDiscount ? AppColors.successDark : AppColors.textPrimary, fontFamily: 'Cairo')),
      ],
    );
  }
}
