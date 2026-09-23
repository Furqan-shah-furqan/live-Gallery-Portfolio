import 'package:flutter/material.dart';

import 'theme_controller.dart';
import '../widgets/liquid_gooey.dart';

/// Warm coral/orange theme inspired by the supplied mobile-finance artwork.
///
/// Existing names such as [cyan] and [violet] are intentionally retained so
/// the rest of the app stays backward-compatible, but their values now belong
/// to the new sunset palette.
abstract final class AppColors {
  static const Color background = Color(0xFFFFA45F);
  static const Color backgroundSoft = Color(0xFFFFF7F3);
  static const Color warmWhite = Color(0xFFFFFCFA);
  static const Color blush = Color(0xFFFFE8E5);

  static const Color ink = Color(0xFF2B1722);
  static const Color inkMuted = Color(0xFF7D5964);

  static const Color orange = Color(0xFFFFA15A);
  static const Color coral = Color(0xFFFF6B70);
  static const Color rose = Color(0xFFF43E70);
  static const Color hotPink = Color(0xFFFF4F87);
  static const Color peach = Color(0xFFFFBE94);
  static const Color sun = Color(0xFFFFD16E);

  // Backward-compatible aliases used throughout the existing UI.
  static const Color cyan = orange;
  static const Color pink = hotPink;
  static const Color violet = coral;

  static const Color green = Color(0xFF43C99A);
  static const Color glass = Color(0xD6FFFFFF);
  static const Color glassStrong = Color(0xF2FFFFFF);
  static const Color danger = Color(0xFFD93662);
  static const Color softShadow = Color(0x308A3F4A);
}

abstract final class AppTheme {
  static ThemeData get lightTheme => themeFor(portfolioPalettes.first);

  static ThemeData themeFor(PortfolioPalette palette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.light,
      surface: palette.surface,
    ).copyWith(
      primary: palette.primary,
      onPrimary: Colors.white,
      secondary: palette.secondary,
      onSecondary: palette.ink,
      tertiary: palette.tertiary,
      error: AppColors.danger,
      surface: palette.surface,
      surfaceContainerHigh: palette.surfaceAlt,
      onSurface: palette.ink,
      onSurfaceVariant: palette.muted,
      primaryContainer: palette.backgroundStart,
      secondaryContainer: palette.backgroundEnd,
      tertiaryContainer: palette.tertiary,
      shadow: palette.ink.withOpacity(0.22),
      inverseSurface: palette.ink,
      inversePrimary: palette.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: palette.surface,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      fontFamily: 'Segoe UI',
      splashColor: palette.primary.withOpacity(0.08),
      highlightColor: palette.secondary.withOpacity(0.07),
      // selectionTheme: const TextSelectionThemeData(
      //   cursorColor: AppColors.rose,
      //   selectionColor: Color(0x4DFF6B82),
      //   selectionHandleColor: AppColors.hotPink,
      // ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w900,
          letterSpacing: -4.5,
          height: 0.94,
        ),
        displayMedium: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w900,
          letterSpacing: -3.2,
          height: 0.98,
        ),
        headlineLarge: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.8,
        ),
        headlineMedium: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        titleLarge: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          color: palette.muted,
          height: 1.65,
        ),
        bodyMedium: TextStyle(
          color: palette.muted,
          height: 1.55,
        ),
        labelLarge: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface.withOpacity(0.90),
        hintStyle: TextStyle(color: palette.muted.withOpacity(0.72)),
        labelStyle: TextStyle(color: palette.muted),
        prefixIconColor: palette.muted,
        suffixIconColor: palette.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(
            palette.surface.withOpacity(0.98),
          ),
          elevation: const WidgetStatePropertyAll<double>(8),
          shadowColor: WidgetStatePropertyAll<Color>(
            palette.ink.withOpacity(0.22),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.ink.withOpacity(0.22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: palette.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  PremiumPageRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 760),
          reverseTransitionDuration: const Duration(milliseconds: 580),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return LiquidGooeyPageTransition(
              animation: animation,
              child: child,
            );
          },
        );
}
