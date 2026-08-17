import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_design_tokens.dart';

class HomeFixStatusChip extends StatelessWidget {
  const HomeFixStatusChip({
    super.key,
    required this.label,
    this.tone = HomeFixStatusTone.neutral,
    this.icon,
  });

  final String label;
  final HomeFixStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = switch (tone) {
      HomeFixStatusTone.neutral => (
          background: AppColors.borderLight,
          foreground: AppColors.textSecondary,
        ),
      HomeFixStatusTone.info => (
          background: AppColors.primaryLight,
          foreground: AppColors.primaryDark,
        ),
      HomeFixStatusTone.success => (
          background: AppColors.successLight,
          foreground: AppColors.successDark,
        ),
      HomeFixStatusTone.warning => (
          background: AppColors.warningLight,
          foreground: AppColors.warningDark,
        ),
      HomeFixStatusTone.error => (
          background: AppColors.errorLight,
          foreground: AppColors.errorDark,
        ),
      HomeFixStatusTone.technician => (
          background: AppColors.technicianLight,
          foreground: AppColors.technicianDark,
        ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space3,
        vertical: AppDesignTokens.space2,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: palette.foreground, size: 16),
            const SizedBox(width: AppDesignTokens.space1),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

enum HomeFixStatusTone {
  neutral,
  info,
  success,
  warning,
  error,
  technician,
}
