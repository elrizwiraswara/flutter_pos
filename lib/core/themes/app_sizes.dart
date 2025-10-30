import 'package:flutter/material.dart';

/// Custom size for common used sizes (e.g. padding)
class AppSizes {
  // Prevents instantiation and extension
  AppSizes._();

  static const double margin = 18;
  static const double padding = 18;
  static const double radius = 8;

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);
  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;
  static double appBarHeight() => AppBar().preferredSize.height;
  static EdgeInsets viewPadding(BuildContext context) => MediaQuery.of(context).padding;
}
