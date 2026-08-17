import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_design_tokens.dart';

class HomeFixButton extends StatelessWidget {
  const HomeFixButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.variant = HomeFixButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final HomeFixButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !loading;
    final Widget child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == HomeFixButtonVariant.primary
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppDesignTokens.space2),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      HomeFixButtonVariant.primary => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      HomeFixButtonVariant.secondary => FilledButton.tonal(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      HomeFixButtonVariant.outline => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      HomeFixButtonVariant.text => TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      HomeFixButtonVariant.destructive => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: child,
        ),
    };

    return expanded ? SizedBox(width: double.infinity, height: AppDesignTokens.buttonHeight, child: button) : button;
  }
}

enum HomeFixButtonVariant {
  primary,
  secondary,
  outline,
  text,
  destructive,
}
