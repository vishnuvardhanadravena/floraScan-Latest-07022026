import 'package:flutter/material.dart';

/// Responsive Design System - Use throughout your entire app
/// This provides consistent responsive behavior across all screen sizes

class ResponsiveHelper {
  /// Screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Device type detection
  static bool isMobile(BuildContext context) {
    return width(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= 600 && width(context) < 1200;
  }

  static bool isLargeTablet(BuildContext context) {
    return width(context) >= 1200;
  }

  /// Unified screen type
  static ScreenType getScreenType(BuildContext context) {
    final w = width(context);
    if (w < 600) return ScreenType.mobile;
    if (w < 1200) return ScreenType.tablet;
    return ScreenType.largeTablet;
  }

  /// Check orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}

enum ScreenType { mobile, tablet, largeTablet }

/// Responsive Spacing System
/// Use this throughout your app for consistent spacing
class ResponsiveSpacing {
  final BuildContext context;

  ResponsiveSpacing(this.context);

  // Padding values based on screen size
  double get xs => ResponsiveHelper.isMobile(context) ? 4 : 6;
  double get sm => ResponsiveHelper.isMobile(context) ? 8 : 12;
  double get md => ResponsiveHelper.isMobile(context) ? 12 : 16;
  double get lg => ResponsiveHelper.isMobile(context) ? 16 : 24;
  double get xl => ResponsiveHelper.isMobile(context) ? 20 : 32;
  double get xxl => ResponsiveHelper.isMobile(context) ? 24 : 40;

  // Screen padding
  double get screenHorizontalPadding {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 16;
    if (screen == ScreenType.tablet) return 24;
    return 48;
  }

  double get screenVerticalPadding {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 12;
    if (screen == ScreenType.tablet) return 16;
    return 24;
  }

  // Card padding
  double get cardPadding {
    return ResponsiveHelper.isMobile(context) ? 12 : 16;
  }

  // List item padding
  double get listItemPadding {
    return ResponsiveHelper.isMobile(context) ? 12 : 16;
  }

  // Border radius
  double get smallRadius => 8;
  double get mediumRadius => 12;
  double get largeRadius => 16;
}

/// Responsive Typography System
/// Use this for all text in your app
class ResponsiveTypography {
  final BuildContext context;

  ResponsiveTypography(this.context);

  // Display sizes
  double get displayLarge {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 32;
    if (screen == ScreenType.tablet) return 40;
    return 48;
  }

  double get displayMedium {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 28;
    if (screen == ScreenType.tablet) return 36;
    return 44;
  }

  double get displaySmall {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 24;
    if (screen == ScreenType.tablet) return 32;
    return 40;
  }

  // Heading sizes
  double get headingLarge {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 24;
    if (screen == ScreenType.tablet) return 28;
    return 32;
  }

  double get headingMedium {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 20;
    if (screen == ScreenType.tablet) return 24;
    return 28;
  }

  double get headingSmall {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 18;
    if (screen == ScreenType.tablet) return 22;
    return 26;
  }

  // Body sizes
  double get bodyLarge {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 16;
    if (screen == ScreenType.tablet) return 17;
    return 18;
  }

  double get bodyMedium {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 14;
    if (screen == ScreenType.tablet) return 15;
    return 16;
  }

  double get bodySmall {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 12;
    if (screen == ScreenType.tablet) return 13;
    return 14;
  }

  double get captionSmall {
    return 10;
  }

  // Label sizes
  double get labelLarge {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 14;
    if (screen == ScreenType.tablet) return 15;
    return 16;
  }

  double get labelMedium {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 12;
    if (screen == ScreenType.tablet) return 13;
    return 14;
  }

  double get labelSmall {
    return 11;
  }
}

/// Responsive Icon Sizes
class ResponsiveIconSize {
  final BuildContext context;

  ResponsiveIconSize(this.context);

  double get xs => ResponsiveHelper.isMobile(context) ? 16 : 20;
  double get sm => ResponsiveHelper.isMobile(context) ? 20 : 24;
  double get md => ResponsiveHelper.isMobile(context) ? 24 : 28;
  double get lg => ResponsiveHelper.isMobile(context) ? 32 : 40;
  double get xl => ResponsiveHelper.isMobile(context) ? 40 : 48;
  double get xxl => ResponsiveHelper.isMobile(context) ? 48 : 56;

  double get appBarIcon => ResponsiveHelper.isMobile(context) ? 24 : 28;
  double get fab => ResponsiveHelper.isMobile(context) ? 56 : 64;
}

/// Responsive Button Size
class ResponsiveButtonSize {
  final BuildContext context;

  ResponsiveButtonSize(this.context);

  double get smallHeight => ResponsiveHelper.isMobile(context) ? 36 : 40;
  double get mediumHeight => ResponsiveHelper.isMobile(context) ? 44 : 48;
  double get largeHeight => ResponsiveHelper.isMobile(context) ? 52 : 56;

  double get smallFontSize => ResponsiveHelper.isMobile(context) ? 12 : 13;
  double get mediumFontSize => ResponsiveHelper.isMobile(context) ? 14 : 15;
  double get largeFontSize => ResponsiveHelper.isMobile(context) ? 16 : 17;

  EdgeInsets get smallPadding {
    return ResponsiveHelper.isMobile(context)
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  }

  EdgeInsets get mediumPadding {
    return ResponsiveHelper.isMobile(context)
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  }

  EdgeInsets get largePadding {
    return ResponsiveHelper.isMobile(context)
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
  }
}

/// Responsive Grid System
class ResponsiveGridHelper {
  final BuildContext context;

  ResponsiveGridHelper(this.context);

  int get crossAxisCount {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 1;
    if (screen == ScreenType.tablet) return 2;
    return 3;
  }

  double get mainAxisSpacing {
    return ResponsiveHelper.isMobile(context) ? 12 : 16;
  }

  double get crossAxisSpacing {
    return ResponsiveHelper.isMobile(context) ? 12 : 16;
  }

  double get childAspectRatio {
    final screen = ResponsiveHelper.getScreenType(context);
    if (screen == ScreenType.mobile) return 0.9;
    if (screen == ScreenType.tablet) return 0.95;
    return 1.0;
  }

  SliverGridDelegate get defaultGridDelegate {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }
}

/// Easy wrapper for responsive design
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ScreenType screenType,
    ResponsiveSpacing spacing,
    ResponsiveTypography typography,
  ) builder;

  const ResponsiveWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSpacing(context);
    final typography = ResponsiveTypography(context);
    final screenType = ResponsiveHelper.getScreenType(context);

    return builder(context, screenType, spacing, typography);
  }
}

/// Quick responsive box
class ResponsiveBox extends StatelessWidget {
  final Widget child;
  final bool addPadding;
  final bool addSafeArea;
  final Color? backgroundColor;

  const ResponsiveBox({
    super.key,
    required this.child,
    this.addPadding = true,
    this.addSafeArea = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSpacing(context);

    Widget result = child;

    if (addPadding) {
      result = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.screenHorizontalPadding,
          vertical: spacing.screenVerticalPadding,
        ),
        child: result,
      );
    }

    if (addSafeArea) {
      result = SafeArea(child: result);
    }

    if (backgroundColor != null) {
      result = Container(
        color: backgroundColor,
        child: result,
      );
    }

    return result;
  }
}

/// Helper extension for easier access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper();
  ResponsiveSpacing get spacing => ResponsiveSpacing(this);
  ResponsiveTypography get typography => ResponsiveTypography(this);
  ResponsiveIconSize get iconSize => ResponsiveIconSize(this);
  ResponsiveButtonSize get buttonSize => ResponsiveButtonSize(this);
  ResponsiveGridHelper get gridHelper => ResponsiveGridHelper(this);
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);

  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isLargeTablet => ResponsiveHelper.isLargeTablet(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
}