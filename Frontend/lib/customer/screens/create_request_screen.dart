import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_field.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/address_model.dart';
import '../../models/service_model.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_request_detail_screen.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key, required this.initialService});
  final ServiceModel initialService;

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  late ServiceModel _service;
  AddressModel? _address;
  final TextEditingController _problemController = TextEditingController();
  String _date = 'اليوم';
  String _time = '04:30 مساءً';
  bool _submitting = false;

  static const _dates = ['اليوم', 'غداً', 'بعد غد'];
  static const _times = ['09:00 صباحاً', '11:30 صباحاً', '02:00 ظهراً', '04:30 مساءً', '07:00 مساءً', '09:00 مساءً'];
  static const _quickTags = ['تسريب ماء', 'ضعف تبريد', 'صوت غير طبيعي', 'مشكلة كهربائية', 'تنظيف', 'تركيب'];

  @override
  void initState() {
    super.initState();
    _service = widget.initialService;
    final state = context.read<AppStateProvider>();
    if (state.savedAddresses.isNotEmpty) _address = state.savedAddresses.first;
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStateProvider state) async {
    if (_submitting) return;
    if (_address == null) {
      _showError('اختر عنوان تقديم الخدمة أولاً.');
      return;
    }
    if (_problemController.text.trim().isEmpty) {
      _showError('اكتب وصفاً مختصراً للمشكلة ليساعد الفني على فهم الطلب.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final request = await state.createServiceRequest(
        service: _service,
        address: _address!,
        problemDescription: _problemController.text.trim(),
        preferredDate: _date,
        preferredTime: _time,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerRequestDetailScreen(requestId: request.id)));
    } catch (error) {
      if (!mounted) return;
      _showError(error is UnsupportedError ? error.message : 'تعذر إرسال الطلب. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final addresses = state.savedAddresses;
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('طلب خدمة')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding.add(const EdgeInsets.symmetric(vertical: AppDesignTokens.space4)),
          child: AppResponsive.content(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeFixCard(
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)),
                        child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: AppDesignTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_service.categoryNameAr, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                            const SizedBox(height: AppDesignTokens.space1),
                            Text(_service.nameAr, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: AppDesignTokens.space1),
                            Text('${_service.pricing.minPrice.toInt()}–${_service.pricing.maxPrice.toInt()} ${_service.pricing.currency}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space5),
                Text('أين نأتيك؟', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDesignTokens.space2),
                if (addresses.isEmpty)
                  HomeFixEmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'أضف عنواناً أولاً',
                    message: 'لا يوجد عنوان محفوظ حالياً. أضف عنواناً من قسم العناوين ثم عد لإكمال الطلب.',
                  )
                else
                  HomeFixCard(
                    child: DropdownButtonFormField<AddressModel>(
                      value: _address,
                      decoration: const InputDecoration(labelText: 'عنوان الخدمة', prefixIcon: Icon(Icons.location_on_outlined)),
                      items: addresses.map((address) => DropdownMenuItem(value: address, child: Text('${address.title} · ${address.city}', overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) => setState(() => _address = value),
                    ),
                  ),
                const SizedBox(height: AppDesignTokens.space5),
                Text('ما المشكلة؟', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDesignTokens.space2),
                Wrap(
                  spacing: AppDesignTokens.space2,
                  runSpacing: AppDesignTokens.space2,
                  children: _quickTags.map((tag) => ActionChip(label: Text(tag), onPressed: () => _appendTag(tag))).toList(),
                ),
                const SizedBox(height: AppDesignTokens.space3),
                HomeFixField(
                  controller: _problemController,
                  label: 'وصف المشكلة',
                  hintText: 'اكتب التفاصيل التي يحتاجها الفني…',
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: AppDesignTokens.space2),
                HomeFixCard(
                  backgroundColor: AppColors.background,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.attach_file_rounded, color: AppColors.textMuted),
                      const SizedBox(width: AppDesignTokens.space2),
                      Expanded(child: Text('إرفاق الصور غير متاح حالياً لأن الـAPI الحالي لا يوفّر رفع ملفات ثنائية. لن يتم عرض أو حفظ مرفق وهمي.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space5),
                Text('الموعد المفضل', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDesignTokens.space2),
                Text('اليوم', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppDesignTokens.space2),
                Wrap(spacing: AppDesignTokens.space2, children: _dates.map((date) => ChoiceChip(label: Text(date), selected: _date == date, onSelected: (_) => setState(() => _date = date))).toList()),
                const SizedBox(height: AppDesignTokens.space3),
                Text('التوقيت', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppDesignTokens.space2),
                Wrap(spacing: AppDesignTokens.space2, runSpacing: AppDesignTokens.space2, children: _times.map((time) => ChoiceChip(label: Text(time), selected: _time == time, onSelected: (_) => setState(() => _time = time)).toList()),
                const SizedBox(height: AppDesignTokens.space5),
                HomeFixCard(
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      const SizedBox(width: AppDesignTokens.space3),
                      Expanded(child: Text('السعر المعروض للخدمة تقديري فقط. السعر النهائي يعتمد على عرض الفني ويؤكده الخادم.', style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space5),
                HomeFixButton(label: 'إرسال طلب الخدمة', icon: Icons.arrow_back_rounded, loading: _submitting, onPressed: _address == null || addresses.isEmpty ? null : () => _submit(state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _appendTag(String tag) {
    final current = _problemController.text.trim();
    _problemController.text = current.isEmpty ? tag : '$current، $tag';
    _problemController.selection = TextSelection.collapsed(offset: _problemController.text.length);
    setState(() {});
  }
}
