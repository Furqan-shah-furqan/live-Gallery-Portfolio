import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aura_bento.dart';

enum PortfolioThemeId {
  auraSunset,
  auroraPeriwinkle,
  porcelainMist,
  sageAtmosphere,
  emberEmber,
  duskLavender,
}

/// A palette-adapted view of the Aura-Bento token set. Every palette keeps
/// the same structural tokens (canvas, white surfaces, ink) and only swaps
/// the two aura mesh hues plus the accent anchors, so contrast ratios and
/// the concentric radius system stay intact across themes.
@immutable
class PortfolioPalette {
  const PortfolioPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.muted,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final PortfolioThemeId id;
  final String name;
  final String description;

  /// Swatch strip shown in the Theme Studio preview card.
  final List<Color> colors;

  /// Aura mesh endpoints rendered behind the app.
  final Color backgroundStart;
  final Color backgroundEnd;

  /// White card surface (kept #FFFFFF for token fidelity).
  final Color surface;
  final Color surfaceAlt;

  /// Deep neutral anchor for typography (#121417 or near-black).
  final Color ink;
  final Color muted;

  /// Accent anchor for CTAs / active states.
  final Color primary;
  final Color secondary;
  final Color tertiary;
}

const List<PortfolioPalette> portfolioPalettes = <PortfolioPalette>[
  PortfolioPalette(
    id: PortfolioThemeId.auraSunset,
    name: 'Aura Sunset',
    description:
        'The canonical Aura-Bento look: peach-periwinkle aura on the neutral #E9EBEF canvas.',
    colors: <Color>[
      Color(0xFFFFC896),
      Color(0xFFFF9A7B),
      Color(0xFFFFA877),
      Color(0xFF6875F5),
      Color(0xFF2A85FF),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFFFC896),
    backgroundEnd: Color(0xFFB4BEFF),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: AuraBento.accentBlueAction,
    secondary: AuraBento.accentOrange,
    tertiary: Color(0xFF6E56CF),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.auroraPeriwinkle,
    name: 'Aurora Periwinkle',
    description: 'Cool periwinkle aura with a blue action anchor for product-style interfaces.',
    colors: <Color>[
      Color(0xFFB4BEFF),
      Color(0xFF8FA8FF),
      Color(0xFF5865F2),
      Color(0xFF2A85FF),
      Color(0xFF6E56CF),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFB4BEFF),
    backgroundEnd: Color(0xFFB9C7FF),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: Color(0xFF3B5BDB),
    secondary: Color(0xFF6E56CF),
    tertiary: AuraBento.accentBlueAction,
  ),
  PortfolioPalette(
    id: PortfolioThemeId.porcelainMist,
    name: 'Porcelain Mist',
    description: 'Quiet porcelain neutrals with the pure black anchor — the most minimal aura.',
    colors: <Color>[
      Color(0xFFF3F4F6),
      Color(0xFFE2E4E8),
      Color(0xFFC9CDD4),
      Color(0xFF8F96A3),
      Color(0xFF111111),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFE7E0F2),
    backgroundEnd: Color(0xFFD8DEE9),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: AuraBento.accentDarkAction,
    secondary: AuraBento.accentBlueAction,
    tertiary: AuraBento.textTertiary,
  ),
  PortfolioPalette(
    id: PortfolioThemeId.sageAtmosphere,
    name: 'Sage Atmosphere',
    description: 'Soft sage mist grounded by the dark neutral anchor for calm, tactile layouts.',
    colors: <Color>[
      Color(0xFFDDE8DE),
      Color(0xFFB8CDB9),
      Color(0xFF8FAF92),
      Color(0xFF5C7F60),
      Color(0xFF2F5D3A),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFDCE8DA),
    backgroundEnd: Color(0xFFC9DCCF),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: Color(0xFF2F6B3C),
    secondary: Color(0xFF5C7F60),
    tertiary: Color(0xFF8FAF92),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.emberEmber,
    name: 'Ember Aura',
    description: 'Warm ember mesh with the orange indicator — high-contrast warmth on the gray canvas.',
    colors: <Color>[
      Color(0xFFFFD9B0),
      Color(0xFFFFB28F),
      Color(0xFFFF8C66),
      Color(0xFFE86927),
      Color(0xFFD96500),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFFFD9B0),
    backgroundEnd: Color(0xFFFFBFA3),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: AuraBento.accentOrange,
    secondary: Color(0xFFD96500),
    tertiary: AuraBento.accentBlueAction,
  ),
  PortfolioPalette(
    id: PortfolioThemeId.duskLavender,
    name: 'Dusk Lavender',
    description: 'Dusky lavender aura with violet anchors — the most atmospheric of the six.',
    colors: <Color>[
      Color(0xFFEDE8FE),
      Color(0xFFD6CBFA),
      Color(0xFFB9A8F4),
      Color(0xFF6E56CF),
      Color(0xFF5865F2),
      Color(0xFF121417),
    ],
    backgroundStart: Color(0xFFE4DBFC),
    backgroundEnd: Color(0xFFCFD6FF),
    surface: AuraBento.surfaceWhite,
    surfaceAlt: AuraBento.surfaceCardMuted,
    ink: AuraBento.textPrimary,
    muted: AuraBento.textSecondary,
    primary: Color(0xFF6E56CF),
    secondary: Color(0xFF5865F2),
    tertiary: AuraBento.accentBlueAction,
  ),
];

class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'portfolio_theme_id';

  PortfolioThemeId _themeId = PortfolioThemeId.auraSunset;

  PortfolioThemeId get themeId => _themeId;

  PortfolioPalette get palette => portfolioPalettes.firstWhere(
        (item) => item.id == _themeId,
        orElse: () => portfolioPalettes.first,
      );

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);

    for (final item in PortfolioThemeId.values) {
      if (item.name == saved) {
        _themeId = item;
        break;
      }
    }
  }

  Future<void> select(PortfolioThemeId value) async {
    if (_themeId == value) return;

    _themeId = value;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, value.name);
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope was not found.');
    return scope!.notifier!;
  }
}
