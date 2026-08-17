import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_design_tokens.dart';

class HomeFixCard extends StatelessWidget {
  const HomeFixCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignTokens.space4),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppColors.cardBackground,
    this.gradient,
    this.borderColor = AppColors.border,
    this.radius = AppDesignTokens.radiusLg,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: gradient == null ? backgroundColor : Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: card,
    );
  }
}

class HomeFixSectionHeader extends StatelessWidget {
  const HomeFixSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingPressed,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppDesignTokens.space1),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTrailingPressed,
            child: Text(trailing!),
          ),
      ],
    );
  }
}
