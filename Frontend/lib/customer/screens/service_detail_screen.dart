import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../models/service_model.dart';
import 'create_request_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  String _formatRange(ServicePricingModel pricing) {
    final min = pricing.minPrice;
    final max = pricing.maxPrice;
    if (min == null && max == null) return 'السعر حسب الموقع';
    if (min != null && max != null) return '${min.toInt()} - ${max.toInt()} ${pricing.currency}';
    if (min != null) return 'من ${min.toInt()} ${pricing.currency}';
    return 'حتى ${max!.toInt()} ${pricing.currency}';
  }

  @override
  Widget build(BuildContext context) {
    final pricing = service.pricing;
    final imageUrl = service.image.trim();
    final imageUri = Uri.tryParse(imageUrl);
    final hasValidImage = imageUri != null &&
        (imageUri.scheme == 'http' || imageUri.scheme == 'https') &&
        imageUri.host.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hasValidImage
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryLight,
                            child: const Icon(
                              Icons.build,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryLight,
                          child: const Icon(
                            Icons.build,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.6)]))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)), child: Text(service.categoryNameAr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo'))),
                  RatingStarsWidget(rating: service.rating, reviewCount: service.reviewCount),
                ]),
                const SizedBox(height: 12),
                Text(service.nameAr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                const SizedBox(height: 6),
                Row(children: const [Icon(Icons.access_time_rounded, size: 16, color: AppColors.textMuted), SizedBox(width: 6)]),
                Text('المدة المقدرة للعمل: ${service.estimatedDuration}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('نطاق التسعير المعتمد', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
                      const SizedBox(height: 2),
                      Text(_formatRange(pricing), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo')),
                    ]),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(8)), child: Text(pricing.visitFee != null ? 'رسوم الكشف: ${pricing.visitFee!.toInt()} ${pricing.currency}' : 'رسوم الكشف حسب الموقع', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'))),
                  ]),
                ),
                const SizedBox(height: 20),
                const Text('نبذة عن الخدمة والضمان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                Text(service.descriptionAr, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6, fontFamily: 'Cairo')),
                const SizedBox(height: 20),
                const Text('ما تشمله الخدمة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                const SizedBox(height: 10),
                _buildIncludedItem('فحص ومعاينة دقيقة للمشكلة بأجهزة حديثة'),
                _buildIncludedItem('تقديم تقرير فني معتمد قبل بدء العمل'),
                _buildIncludedItem('ضمان رسمي لمدة 30 يوماً على جودة الخدمة'),
                _buildIncludedItem('تنظيف موقع العمل بعد انتهاء الصيانة'),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.border)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRequestScreen(initialService: service))),
          child: const Text('طلب هذه الخدمة الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Cairo')))]));
  }
}
