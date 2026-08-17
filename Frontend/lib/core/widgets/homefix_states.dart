import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_design_tokens.dart';

class HomeFixSkeleton extends StatelessWidget {
  const HomeFixSkeleton({super.key, this.width, this.height, this.radius = AppDesignTokens.radiusMd});
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(radius)),
      );
}

class HomeFixLoadingList extends StatelessWidget {
  const HomeFixLoadingList({super.key, this.itemCount = 5});
  final int itemCount;
  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppDesignTokens.space3),
        itemBuilder: (_, __) => const Row(
          children: [
            HomeFixSkeleton(width: 52, height: 52, radius: AppDesignTokens.radiusSm),
            SizedBox(width: AppDesignTokens.space3),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [HomeFixSkeleton(width: 170, height: 14), SizedBox(height: AppDesignTokens.space2), HomeFixSkeleton(width: 110, height: 11)])),
          ],
        ),
      );
}

class HomeFixSkeletonList extends HomeFixLoadingList {
  const HomeFixSkeletonList({super.key, super.itemCount});
}

class HomeFixEmptyState extends StatelessWidget {
  const HomeFixEmptyState({super.key, required this.icon, required this.title, required this.message, this.showRetry = false, this.onRetry});
  final IconData icon;
  final String title;
  final String message;
  final bool showRetry;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.space6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
              child: Padding(padding: const EdgeInsets.all(AppDesignTokens.space4), child: Icon(icon, color: AppColors.primaryDark, size: 30)),
            ),
            const SizedBox(height: AppDesignTokens.space4),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDesignTokens.space2),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: AppDesignTokens.space5),
              FilledButton.tonalIcon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة المحاولة')),
            ],
          ]),
        ),
      );
}

class HomeFixErrorState extends StatelessWidget {
  const HomeFixErrorState({super.key, required this.title, this.message, this.retryLabel = 'إعادة المحاولة', this.onRetry, this.icon = Icons.cloud_off_rounded});
  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;
  @override
  Widget build(BuildContext context) => HomeFixEmptyState(icon: icon, title: title, message: message ?? '', showRetry: onRetry != null, onRetry: onRetry);
}

class HomeFixSuccessBanner extends StatelessWidget {
  const HomeFixSuccessBanner({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space4, vertical: AppDesignTokens.space3),
        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd), border: Border.all(color: AppColors.success.withValues(alpha: 0.22))),
        child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.successDark, size: 20), const SizedBox(width: AppDesignTokens.space2), Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.successDark)))]),
      );
}
