import 'package:flutter/material.dart';

/// Which size bucket the current screen falls into.
enum ScreenSize { mobile, tablet, desktop }

/// Helpers that let one set of screens look right on a phone and on a
/// wide browser window.
class Responsive {
  const Responsive._();

  static const double mobileBreakpoint = 640;
  static const double tabletBreakpoint = 1024;

  /// The widest the content is ever allowed to stretch. On a large monitor
  /// the app stays centred in a readable column instead of spreading out.
  static const double maxContentWidth = 1080;

  static ScreenSize sizeOf(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      sizeOf(context) == ScreenSize.mobile;

  static bool isDesktop(BuildContext context) =>
      sizeOf(context) == ScreenSize.desktop;

  /// How many restaurant cards sit side by side.
  static int gridColumns(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
    }
  }

  /// Horizontal page padding, roomier on bigger screens.
  static double pagePadding(BuildContext context) =>
      isMobile(context) ? 16 : 24;
}

/// Wraps content so it never stretches uncomfortably wide on a desktop
/// browser, while staying edge-to-edge on a phone.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
