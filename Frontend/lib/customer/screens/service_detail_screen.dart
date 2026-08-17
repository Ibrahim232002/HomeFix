import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_model.dart';
import 'create_request_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(service.nameAr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppResponsive.pagePadding(context).add(const EdgeInsets.symmetric(vertical: AppDesignTokens.space5)),
                child: AppResponsive.content(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Hero(service: service),
                      const SizedBox(height: AppDesignTokens.space5),
                      Row(
                        children: [
                          HomeFixStatusChip(label: service.categoryNameAr, color: AppColors.primary),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: AppColors.warningDark),
                              const SizedBox(width: 4),
                              Text('${service.rating.toStringAsFixed(1)} · ${service.reviewCount} تقييم', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignTokens.space2),
                      Text(service.nameAr, style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: AppDesignTokens.space2),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text('المدة المتوقعة: ${service.estimatedDuration}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: AppDesignTokens.space5),
                      HomeFixCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('نطاق السعر المعتمد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                                  const SizedBox(height: AppDesignTokens.space1),
                                  Text('${service.pricing.minPrice.toInt()} – ${service.pricing.maxPrice.toInt()} ${service.pricing.currency}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryDark)),
                                ],
                              ),
                            ),
                            if (service.pricing.visitFee > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space3, vertical: AppDesignTokens.space2),
                                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)),
                                child: Text('زيارة ${service.pricing.visitFee.toInt()} ${service.pricing.currency}', style: Theme.of(context).textTheme.labelMedium),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.space6),
                      Text('عن الخدمة', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppDesignTokens.space2),
                      Text(service.descriptionAr.isEmpty ? 'تفاصيل الخدمة يحددها مقدم الخدمة وفق نطاق العمل الفعلي.' : service.descriptionAr, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                      if (service.features.isNotEmpty) ...[
                        const SizedBox(height: AppDesignTokens.space6),
                        Text('تشمل الخدمة', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppDesignTokens.space2),
                        ...service.features.map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: AppDesignTokens.space2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 19, color: AppColors.successDark),
                                  const SizedBox(width: AppDesignTokens.space2),
                                  Expanded(child: Text(feature, style: Theme.of(context).textTheme.bodyMedium)),
                                ],
                              ),
                            )),
                      ],
                      const SizedBox(height: AppDesignTokens.space8),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(AppDesignTokens.space4, AppDesignTokens.space3, AppDesignTokens.space4, MediaQuery.paddingOf(context).bottom + AppDesignTokens.space3),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 18, offset: const Offset(0, -4))]),
              child: HomeFixButton(
                label: 'اطلب هذه الخدمة',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRequestScreen(initialService: service))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return HomeFixCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
          child: service.image.isNotEmpty
              ? Image.network(service.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(color: AppColors.primarySurface, child: const Center(child: Icon(Icons.home_repair_service_rounded, size: 64, color: AppColors.primary)));
}
