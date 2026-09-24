import 'package:flutter/material.dart';

import 'aura_bento.dart';
import 'theme_controller.dart';
import '../widgets/liquid_gooey.dart';

/// App-level aliases over the canonical [AuraBento] tokens.
///
/// Legacy names (cyan/pink/violet/glass…) are retained so the rest of the
/// app keeps compiling, but every value now belongs to the Aura-Bento
/// neutral + blue/orange accent system.
abstract final class AppColors {
  // Canvas & surfaces
  static const Color background = AuraBento.canvasLight;
  static const Color backgroundSoft = AuraBento.canvasLightSecondary;
  static const Color warmWhite = AuraBento.surfaceWhite;
  static const Color blush = AuraBento.surfaceCardMuted;

  // Text anchors
  static const Color ink = AuraBento.textPrimary;
  static const Color inkMuted = AuraBento.textSecondary;
  static const Color inkFaint = AuraBento.textTertiary;

  // Accents
  static const Color orange = AuraBento.accentOrange;
  static const Color coral = AuraBento.accentOrangeIndicator;
  static const Color blue = AuraBento.accentBlueAction;
  static const Color hotPink = AuraBento.accentBlueAction;

  // Backward-compatible aliases consumed throughout the existing UI.
  static const Color cyan = AuraBento.accentBlueAction;
  static const Color pink = AuraBento.accentOrange;
  static const Color violet = Color(0xFF6E56CF);

  static const Color green = AuraBento.accentBlueAction;
  static const Color glass = AuraBento.surfaceWhiteTranslucent;
  static const Color glassStrong = Color(0xF2FFFFFF);
  static const Color danger = Color(0xFFD93662);
  static const Color softShadow = Color(0xFF111827);
}

/// Light-only Aura-Bento ThemeData: white bento cards on the neutral canvas,
/// high-radius squircles, pill inputs, and #2A85FF focus rings.
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
      onSecondary: Colors.white,
      tertiary: palette.tertiary,
      error: AppColors.danger,
      surface: palette.surface,
      surfaceContainerHigh: palette.surfaceAlt,
      onSurface: palette.ink,
      onSurfaceVariant: palette.muted,
      primaryContainer: palette.backgroundStart,
      secondaryContainer: palette.backgroundEnd,
      tertiaryContainer: palette.tertiary,
      shadow: const Color(0xFF111827),
      inverseSurface: AuraBento.surfaceDarkHud,
      inversePrimary: palette.surface,
    );

    final serifBase = TextStyle(
      fontFamily: AuraBento.fontSerif,
      color: palette.ink,
      fontWeight: FontWeight.w400,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: palette.surface,
      splashColor: AuraBento.accentBlueGlow,
      highlightColor: AuraBento.accentBlueGlow.withAlpha(70),
      focusColor: AuraBento.accentBlueAction.withAlpha(46),
      fontFamily: AuraBento.fontSans,
      // §7 a11y: 2px #2A85FF ring, 2px offset on every focused control.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: TextTheme(
        // Conversational display faces use the serif; interface chrome stays sans.
        displayLarge: serifBase.copyWith(
          fontSize: 58,
          height: 1.05,
          letterSpacing: -0.5,
        ),
        displayMedium: serifBase.copyWith(
          fontSize: 40,
          height: 1.1,
          letterSpacing: -0.3,
        ),
        displaySmall: serifBase.copyWith(
          fontSize: 32,
          height: 38 / 32,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          color: palette.ink,
          fontSize: 24,
          height: 30 / 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineMedium: TextStyle(
          color: palette.ink,
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        headlineSmall: TextStyle(
          color: palette.ink,
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: palette.ink,
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: palette.ink,
          fontSize: 15,
          height: 22 / 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleSmall: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 18 / 13,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: palette.muted,
          fontSize: 15,
          height: 22 / 15,
        ),
        bodyMedium: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 20 / 13,
        ),
        bodySmall: TextStyle(
          color: palette.muted,
          fontSize: 12,
          height: 18 / 12,
        ),
        labelLarge: TextStyle(
          color: palette.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        labelMedium: TextStyle(
          color: palette.muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: palette.muted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraBento.surfaceWhite,
        hintStyle: const TextStyle(color: AuraBento.textTertiary),
        labelStyle: TextStyle(color: palette.muted),
        prefixIconColor: AuraBento.textTertiary,
        suffixIconColor: AuraBento.textTertiary,
        // §4.1 Input Capsule: full pill, white surface, no harsh borders.
        border: _pillBorder(AuraBento.surfacePillNeutralSolid),
        enabledBorder: _pillBorder(AuraBento.surfacePillNeutralSolid),
        focusedBorder: _pillBorder(AuraBento.accentBlueAction, width: 2),
        errorBorder: _pillBorder(AppColors.danger),
        focusedErrorBorder: _pillBorder(AppColors.danger, width: 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AuraBento.space5,
          vertical: AuraBento.space4,
        ),
        constraints: const BoxConstraints(
          minHeight: AuraBento.inputHeightCompact,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor:
              const WidgetStatePropertyAll<Color>(AuraBento.surfaceWhite),
          elevation: const WidgetStatePropertyAll<double>(8),
          shadowColor: WidgetStatePropertyAll<Color>(
            const Color(0xFF111827).withAlpha(46),
          ),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            AuraBento.surfaceWhite,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuraBento.radiusMd),
            ),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AuraBento.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0xFF111827).withAlpha(26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraBento.radiusXl),
        ),
      ),
      cardTheme: CardTheme(
        color: AuraBento.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraBento.radiusLg),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AuraBento.accentDarkAction,
        foregroundColor: AuraBento.textInverted,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraBento.radiusSm),
        ),
        backgroundColor: AuraBento.surfaceDarkHud,
        contentTextStyle: const TextStyle(
          color: AuraBento.textInverted,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AuraBento.surfacePillNeutralSolid,
        thickness: 1,
        space: 1,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.ink,
          focusColor: AuraBento.accentBlueGlow,
        ),
      ),
    );
  }

  static OutlineInputBorder _pillBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraBento.radiusFull),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  PremiumPageRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 620),
          reverseTransitionDuration: const Duration(milliseconds: 460),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return LiquidGooeyPageTransition(
              animation: animation,
              child: child,
            );
          },
        );
}
