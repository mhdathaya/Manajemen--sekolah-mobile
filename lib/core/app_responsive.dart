import 'package:flutter/material.dart';

/// Helper responsif untuk semua screen.
/// Breakpoints:
///   phone   : width < 600
///   tablet  : 600 <= width < 900
///   desktop : width >= 900
class AppResponsive {
  AppResponsive._();

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 900;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// Padding horizontal responsif
  static double hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return w * 0.12;
    if (w >= 600) return w * 0.06;
    return 16;
  }

  /// Jumlah kolom grid menu responsif
  static int menuCols(BuildContext context, {int phone = 3, int tablet = 4, int desktop = 5}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return phone;
  }

  /// childAspectRatio untuk grid menu responsif
  static double menuRatio(BuildContext context) {
    if (isDesktop(context)) return 1.1;
    if (isTablet(context)) return 1.05;
    return 0.95;
  }

  /// Font size responsif (scale naik di tablet/desktop)
  static double fontSize(BuildContext context, double base) {
    if (isDesktop(context)) return base + 2;
    if (isTablet(context)) return base + 1;
    return base;
  }

  /// Widget responsif — pilih child sesuai breakpoint
  static Widget builder(
    BuildContext context, {
    required Widget phone,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? phone;
    if (isTablet(context)) return tablet ?? phone;
    return phone;
  }
}
