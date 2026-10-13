import 'package:flutter/material.dart';

/// Shared visual values for Lumi Market.
abstract final class AppColors {
  static const coral = Color(0xFFC98B7D);
  static const coralDark = Color(0xFFA85E52);
  static const coralSoft = Color(0xFFF8ECE8);
  static const teal = Color(0xFF587D73);
  static const tealSoft = Color(0xFFEAF2EE);
  static const ink = Color(0xFF414447);
  static const muted = Color(0xFF777C80);
  static const canvas = Color(0xFFFBF9F6);
  static const line = Color(0xFFEDE9E4);
  static const white = Color(0xFFFFFFFF);

  static const productTech = Color(0xFFECEEF2);
  static const productFashion = Color(0xFFF1ECE6);
  static const productBeauty = Color(0xFFF7EDEA);
  static const productHome = Color(0xFFEFF2E9);
  static const productLifestyle = Color(0xFFEAF1EF);
  static const productFood = Color(0xFFF2EEE8);
  static const productTechInk = Color(0xFF7B8796);
  static const productFashionInk = Color(0xFFA28A76);
  static const productBeautyInk = Color(0xFFB68B88);
  static const productHomeInk = Color(0xFF829B84);
  static const productLifestyleInk = Color(0xFF7E9E98);
  static const productFoodInk = Color(0xFFA18D73);

  static const darkCanvas = Color(0xFF1D2524);
  static const darkSurface = Color(0xFF28312F);
  static const darkLine = Color(0xFF3B4844);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 100.0;
}

abstract final class AppBreakpoints {
  static const navigationRail = 720.0;
  static const extendedRail = 1100.0;
  static const contentMaxWidth = 1200.0;
}
