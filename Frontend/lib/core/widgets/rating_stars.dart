import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
export 'empty_state.dart';

class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final bool showNumber;

  const RatingStarsWidget({
    Key? key,
    required this.rating,
    this.reviewCount,
    this.starSize = 14,
    this.showNumber = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, size: starSize, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 4),
        if (showNumber)
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ],
    );
  }
}

