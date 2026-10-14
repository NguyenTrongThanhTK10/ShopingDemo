import 'package:flutter/material.dart';

import 'design_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final background = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final foreground = isDark ? AppColors.white : AppColors.ink;
    final muted = isDark ? const Color(0xFFB2B7C0) : AppColors.muted;
    final outline = isDark ? AppColors.darkLine : AppColors.line;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.coral,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFFFF8B69) : AppColors.coralDark,
          onPrimary: isDark ? const Color(0xFF38190E) : AppColors.white,
          primaryContainer: isDark
              ? const Color(0xFF563026)
              : AppColors.coralSoft,
          onPrimaryContainer: isDark
              ? const Color(0xFFFFD9CB)
              : AppColors.coralDark,
          secondary: isDark ? const Color(0xFF9AD6CA) : AppColors.teal,
          secondaryContainer: isDark
              ? const Color(0xFF294640)
              : AppColors.tealSoft,
          onSecondaryContainer: isDark
              ? const Color(0xFFD9EFE3)
              : const Color(0xFF3B665B),
          tertiary: isDark ? const Color(0xFFFFC66B) : const Color(0xFFE99B28),
          tertiaryContainer: isDark
              ? const Color(0xFF4B4035)
              : const Color(0xFFF5EEE5),
          onTertiaryContainer: isDark
              ? const Color(0xFFF2E4D1)
              : const Color(0xFF6B513A),
          surface: surface,
          onSurface: foreground,
          onSurfaceVariant: muted,
          outline: outline,
          outlineVariant: outline,
          surfaceContainerLow: isDark
              ? const Color(0xFF2D3734)
              : const Color(0xFFF5F6F8),
        );

    final textTheme = ThemeData(useMaterial3: true, brightness: brightness)
        .textTheme
        .apply(bodyColor: foreground, displayColor: foreground)
        .copyWith(
          headlineLarge: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: foreground,
          ),
          headlineMedium: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: foreground,
          ),
          titleLarge: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: foreground,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: foreground),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: foreground),
          bodySmall: TextStyle(fontSize: 12, height: 1.45, color: muted),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: muted,
        indicatorColor: colorScheme.primary,
        dividerColor: outline,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: outline),
        ),
      ),
      dividerColor: outline,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : muted,
            size: 30,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? colorScheme.primary : muted,
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: muted),
      ),
    );
  }
}
