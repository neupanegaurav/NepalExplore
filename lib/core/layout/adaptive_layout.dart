import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppAdaptiveLayout {
  const AppAdaptiveLayout._();

  static const double tabletBreakpoint = 700;
  static const double desktopBreakpoint = 1100;

  static bool useTabletLayout(BuildContext context, {double? width}) {
    final size = MediaQuery.sizeOf(context);
    final resolvedWidth = width ?? size.width;
    final shortestSide = math.min(size.width, size.height);

    return resolvedWidth >= tabletBreakpoint ||
        shortestSide >= 600;
  }

  static bool useDesktopLayout(BuildContext context, {double? width}) {
    final resolvedWidth = width ?? MediaQuery.sizeOf(context).width;
    return resolvedWidth >= desktopBreakpoint;
  }

  static double contentMaxWidthFor(double width) {
    if (width >= 1280) {
      return 1120;
    }
    if (width >= tabletBreakpoint) {
      return 960;
    }
    return width;
  }

  static EdgeInsets pagePadding(BuildContext context, {double? width}) {
    final useTablet = useTabletLayout(context, width: width);
    return EdgeInsets.symmetric(
      horizontal: useTablet ? 24 : 16,
      vertical: useTablet ? 24 : 16,
    );
  }

}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    super.key,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedMaxWidth =
            maxWidth ??
            AppAdaptiveLayout.contentMaxWidthFor(constraints.maxWidth);
        final resolvedPadding =
            padding ??
            AppAdaptiveLayout.pagePadding(context, width: constraints.maxWidth);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
            child: Padding(padding: resolvedPadding, child: child),
          ),
        );
      },
    );
  }
}
