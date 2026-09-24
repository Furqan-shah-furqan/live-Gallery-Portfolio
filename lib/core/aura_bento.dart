import 'package:flutter/material.dart';

/// Aura-Bento Design System — canonical token set (design.md v1.0.0).
///
/// Single source of truth for color, radius, spacing, elevation and
/// typography tokens. All UI code should consume these values (or the
/// palette-adapted variants in [app_theme.dart]) instead of hardcoding.
abstract final class AuraBento {
  // ── Canvas ────────────────────────────────────────────────────────────
  /// Neutral gray canvas base (#E9EBEF light / #0A0B0E dark).
  static const Color canvasLight = Color(0xFFE9EBEF);
  static const Color canvasLightSecondary = Color(0xFFF3F4F6);
  static const Color canvasDark = Color(0xFF0A0B0E);

  // ── Surfaces ──────────────────────────────────────────────────────────
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceWhiteTranslucent = Color(0xD9FFFFFF); // 85%
  static const Color surfaceCardMuted = Color(0xFFF5F6F8);
  static const Color surfacePillNeutral = Color(0x0D000000); // 5% black
  static const Color surfacePillNeutralSolid = Color(0xFFE2E4E8);
  static const Color surfaceDarkHud = Color(0xFF0A0A0A);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF121417);
  static const Color textSecondary = Color(0xFF636A75);
  static const Color textTertiary = Color(0xFF8F96A3);
  static const Color textInverted = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFB0B5BD);

  // ── Accents ───────────────────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFE86927);
  static const Color accentBlueAction = Color(0xFF2A85FF);
  static const Color accentBlueGlow = Color(0x592A85FF); // 35%
  static const Color accentOrangeIndicator = Color(0xFFFF7A00);
  static const Color accentDarkAction = Color(0xFF111111);

  // ── Pill badge tints (dark text tokens keep 4.5:1 over the wash) ──────
  static const Color badgeNeutralBg = Color(0xFFECEEF2);
  static const Color badgeNeutralText = Color(0xFF3D434C);
  static const Color badgeAmberBg = Color(0xFFFEEED8);
  static const Color badgeAmberText = Color(0xFFD96500);
  static const Color badgeLavenderBg = Color(0xFFEDE8FE);
  static const Color badgeLavenderText = Color(0xFF6E56CF);

  /// Semantic success (used for status dots, completed HUD nodes).
  static const Color success = Color(0xFF2A85FF);

  // ── Border radii ──────────────────────────────────────────────────────
  static const double radiusXs = 8; // inner chips
  static const double radiusSm = 14; // inline indicators / small pills
  static const double radiusMd = 20; // mid-size inputs / secondary containers
  static const double radiusLg = 28; // standard bento card corners
  static const double radiusXl = 36; // large hero modules
  static const double radiusFull = 9999; // pills / action buttons

  // ── Spacing (8pt grid, 4pt sub-grid) ─────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // ── Bento grid metrics ────────────────────────────────────────────────
  static const double cardGapCompact = 16; // < 600px
  static const double cardGapDesktop = 24; // > 1024px
  static const double canvasMargin = 20; // safe-area padding

  // ── Component dimensions ──────────────────────────────────────────────
  static const double touchTarget = 44; // minimum hit area
  static const double heroTarget = 52; // hero circular action token
  static const double inputHeight = 52;
  static const double inputHeightCompact = 44;
  static const double ctaHeight = 48;
  static const double badgeHeight = 32;
  static const double hudNodeSize = 24;
  static const double hudConnectorHeight = 4;

  // ── Aura mesh gradients (CSS-parity references) ───────────────────────
  /// mesh-sunset: radial(at 0% 0%, #FF9A7B → transparent 55%),
  ///              radial(at 100% 100%, #5865F2 → transparent 65%), #FFA877.
  static const List<Color> meshSunsetStops = <Color>[
    Color(0xFFFF9A7B),
    Color(0xFF5865F2),
    Color(0xFFFFA877),
  ];

  /// mesh-ambient: warm peach glow at 10%/20% + periwinkle glow at 90%/80%.
  static const List<Color> meshAmbientStops = <Color>[
    Color(0x73FFC896), // rgba(255,200,150,.45)
    Color(0x80B4BEFF), // rgba(180,190,255,.50)
  ];

  /// mesh-card: linear 135°, #FFB28F 70% → #BAB2FF 80%.
  static const List<Color> meshCardStops = <Color>[
    Color(0xB3FFB28F), // rgba(255,178,143,.70)
    Color(0xCCBAB2FF), // rgba(186,178,255,.80)
  ];

  /// Aurora gradient for the primary CTA (§4.4 Aurora Gradient Pill).
  static const List<Color> auroraCta = <Color>[
    Color(0xFFFF8C66),
    Color(0xFF6875F5),
  ];

  /// Blue glow ring used on focused inputs and the hero action token.
  static const Color glowBlue = Color(0x592A85FF); // rgba(42,133,255,.35)

  // ── Elevation ─────────────────────────────────────────────────────────
  /// Ambient card lift against the neutral gray canvas (low opacity, high blur).
  static List<BoxShadow> ambientSm(Color ink) => <BoxShadow>[
        BoxShadow(
          color: ink.withAlpha(10), // ≤4%
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> ambientMd(Color ink) => <BoxShadow>[
        BoxShadow(
          color: ink.withAlpha(18), // ~7%
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> ambientLg(Color ink) => <BoxShadow>[
        BoxShadow(
          color: ink.withAlpha(26), // ~10%
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
      ];

  /// Capsule lift for floating pills and action tokens.
  static List<BoxShadow> capsuleLift = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withAlpha(46), // 18%
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Soft inner stroke replacing harsh borders (light / dark variants).
  static List<BoxShadow> innerStrokeLight = <BoxShadow>[
    const BoxShadow(
      color: Color(0x99FFFFFF), // inset 0 1px 1px rgba(255,255,255,.6)
      blurRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ── Typography ────────────────────────────────────────────────────────
  static const String fontSans = 'Inter';
  static const String fontSerif = 'InstrumentSerif';

  // ── Radii math ────────────────────────────────────────────────────────
  /// Concentric geometry rule: R_inner = R_outer − padding.
  /// Clamped to ≥0 so deeply nested containers stay valid.
  static double innerRadius(double outerRadius, double padding) =>
      (outerRadius - padding).clamp(0.0, double.infinity);

  /// Extra optical inset pushed into cards with radius ≥ 24 (§6).
  static double opticalInset(double radius) => radius >= 24 ? 4 : 0;
}
