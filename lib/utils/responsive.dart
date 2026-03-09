import 'package:flutter/material.dart';

class R {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1000;

  static double h(
    BuildContext context, {
    required double mobile,
    required double desktop,
  }) => isMobile(context) ? mobile : desktop;

  static EdgeInsets padding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: isMobile(context)
        ? 20
        : isTablet(context)
        ? 32
        : 64,
    vertical: isMobile(context) ? 40 : 72,
  );

  static EdgeInsets hPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: isMobile(context)
        ? 20
        : isTablet(context)
        ? 32
        : 64,
  );
}
