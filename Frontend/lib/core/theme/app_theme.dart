import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../constants/app_colors.dart';
import 'app_design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = AppDesignTokens.baseTextTheme.apply(
      fontFamily: 'Cairo',
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.technicianPrimary,
      onSecondary: Colors.white,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo',
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: AppDesignTokens.elevationCard,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.space4,
          vertical: AppDesignTokens.space3,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        helperStyle: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.5),
        disabledBorder: _inputBorder(AppColors.borderLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, AppDesignTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space5),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppDesignTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space5),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppDesignTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space5),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppDesignTokens.minTouchTarget, AppDesignTokens.minTouchTarget),
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space2),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primaryDark),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppDesignTokens.minTouchTarget, AppDesignTokens.minTouchTarget),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: AppColors.textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.borderLight,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.borderLight,
        secondarySelectedColor: AppColors.technicianLight,
        padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space2),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
        ),
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        modalElevation: AppDesignTokens.elevationSheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDesignTokens.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: AppDesignTokens.elevationDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusXl),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppDesignTokens.navHeight,
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        elevation: 8,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppDesignTokens.space2,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.space4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
