import 'package:flutter/material.dart';

/// Shared visual values for Lumi Market.
abstract final class AppColors {
  static const coral = Color(0xFFF45A31);
  static const coralDark = Color(0xFFE84B26);
  static const coralSoft = Color(0xFFFFEDE7);
  static const teal = Color(0xFF276D68);
  static const tealSoft = Color(0xFFE8F5F1);
  static const ink = Color(0xFF22252B);
  static const muted = Color(0xFF737981);
  static const canvas = Color(0xFFF5F6F8);
  static const line = Color(0xFFE9EBEF);
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

  static const darkCanvas = Color(0xFF17191E);
  static const darkSurface = Color(0xFF24272D);
  static const darkLine = Color(0xFF363A42);
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
