import 'package:flutter/widgets.dart';

import 'app_design_tokens.dart';

class AppResponsive {
  AppResponsive._();

  static const double compactBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double wideBreakpoint = 1024;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: AppDesignTokens.space8);
    }
    if (width >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: AppDesignTokens.space6);
    }
    return const EdgeInsets.symmetric(horizontal: AppDesignTokens.space4);
  }

  static double contentWidth(BuildContext context, {bool wide = false}) {
    final maxWidth = wide
        ? AppDesignTokens.wideContentMaxWidth
        : AppDesignTokens.contentMaxWidth;
    return maxWidth;
  }
}

class HomeFixContent extends StatelessWidget {
  const HomeFixContent({
    super.key,
    required this.child,
    this.wide = false,
    this.padding,
  });

  final Widget child;
  final bool wide;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? AppResponsive.pagePadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppResponsive.contentWidth(context, wide: wide),
        ),
        child: Padding(padding: resolvedPadding, child: child),
      ),
    );
  }
}
