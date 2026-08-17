import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_field.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_model.dart';
import '../../services/app_state_provider.dart';
import 'service_detail_screen.dart';

class CustomerServicesScreen extends StatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _categoryId = 'all';
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(AppStateProvider state, String query) async {
    setState(() => _searching = true);
    try {
      await state.setSearchQuery(query.trim());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectCategory(AppStateProvider state, String categoryId) async {
    setState(() => _categoryId = categoryId);
    try {
      await state.selectCategory(categoryId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final services = state.services;
    final padding = AppResponsive.pagePadding(context).horizontal / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الخدمات'),
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshPublicData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppResponsive.content(
                context,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppDesignTokens.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اختار الخدمة المناسبة', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppDesignTokens.space1),
                      Text(
                        'خدمات منزلية موثوقة، واضحة، ومصممة لتوصلّك للطلب المناسب بأقل خطوات.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDesignTokens.space4),
                      HomeFixField(
                        controller: _searchController,
                        label: 'ابحث عن خدمة',
                        hintText: 'مثال: تكييف، سباكة، كهرباء',
                        prefixIcon: Icons.search_rounded,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) => _search(state, value),
                        suffixIcon: _searching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                      ),
                      const SizedBox(height: AppDesignTokens.space4),
                    ],
                  ),
                ),
              ),
            ),
            if (state.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDesignTokens.space2),
                    itemBuilder: (_, index) {
                      final selected = index == 0 ? _categoryId == 'all' : _categoryId == state.categories[index - 1].id;
                      final label = index == 0 ? 'الكل' : state.categories[index - 1].nameAr;
                      return FilterChip(
                        selected: selected,
                        label: Text(label),
                        avatar: Icon(index == 0 ? Icons.grid_view_rounded : Icons.home_repair_service_rounded, size: 18),
                        onSelected: (_) => _selectCategory(state, index == 0 ? 'all' : state.categories[index - 1].id),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(child: const SizedBox(height: AppDesignTokens.space4)),
            if (state.isLoadingPublic && services.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: const SliverToBoxAdapter(child: HomeFixSkeletonList(itemCount: 5)),
              )
            else if (!state.isLoadingPublic && services.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverToBoxAdapter(
                  child: HomeFixErrorState(
                    title: 'لا توجد خدمات متاحة الآن',
                    message: 'تعذر تحميل الخدمات أو لا توجد نتائج مطابقة للبحث.',
                    onRetry: () => state.refreshPublicData(),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, AppDesignTokens.space8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ServiceCard(service: services[index]),
                    childCount: services.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppResponsive.columns(context),
                    crossAxisSpacing: AppDesignTokens.space3,
                    mainAxisSpacing: AppDesignTokens.space3,
                    childAspectRatio: 0.82,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return HomeFixCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDesignTokens.radiusLg)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (service.image.isNotEmpty)
                    Image.network(service.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                  else
                    _fallback(),
                  Positioned(
                    top: AppDesignTokens.space2,
                    right: AppDesignTokens.space2,
                    child: HomeFixStatusChip(
                      label: service.isPopular ? 'الأكثر طلباً' : service.categoryNameAr,
                      color: service.isPopular ? AppColors.technicianPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDesignTokens.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.nameAr, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDesignTokens.space1),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.warningDark),
                    const SizedBox(width: 4),
                    Text('${service.rating.toStringAsFixed(1)} (${service.reviewCount})', style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    Text(
                      '${service.pricing.minPrice.toInt()}–${service.pricing.maxPrice.toInt()} ${service.pricing.currency}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.primarySurface,
        child: const Center(child: Icon(Icons.home_repair_service_rounded, size: 48, color: AppColors.primary)),
      );
}
