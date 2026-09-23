import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PortfolioThemeId {
  coralOriginal,
  warmPlum,
  tealSand,
  forestMist,
  burgundyCoffee,
  roseCocoa,
}

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
  final List<Color> colors;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color muted;
  final Color primary;
  final Color secondary;
  final Color tertiary;
}

const List<PortfolioPalette> portfolioPalettes = <PortfolioPalette>[
  PortfolioPalette(
    id: PortfolioThemeId.coralOriginal,
    name: 'Original Coral',
    description: 'The existing warm coral portfolio theme.',
    colors: <Color>[
      Color(0xFFFFFCFA),
      Color(0xFFFFE8E5),
      Color(0xFFFFA15A),
      Color(0xFFFF6B70),
      Color(0xFFF43E70),
      Color(0xFF2B1722),
    ],
    backgroundStart: Color(0xFFFFB35F),
    backgroundEnd: Color(0xFFE93368),
    surface: Color(0xFFFFFCFA),
    surfaceAlt: Color(0xFFFFE8E5),
    ink: Color(0xFF2B1722),
    muted: Color(0xFF7D5964),
    primary: Color(0xFFF43E70),
    secondary: Color(0xFFFFA15A),
    tertiary: Color(0xFFFFD16E),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.warmPlum,
    name: 'Warm Plum',
    description: 'Soft peach surfaces with rich plum depth.',
    colors: <Color>[
      Color(0xFFFAE5D8),
      Color(0xFFDFB6B2),
      Color(0xFF824D69),
      Color(0xFF522959),
      Color(0xFF2A114B),
      Color(0xFF180018),
    ],
    backgroundStart: Color(0xFFFAE5D8),
    backgroundEnd: Color(0xFF522959),
    surface: Color(0xFFFFF6F0),
    surfaceAlt: Color(0xFFDFB6B2),
    ink: Color(0xFF180018),
    muted: Color(0xFF824D69),
    primary: Color(0xFF522959),
    secondary: Color(0xFF824D69),
    tertiary: Color(0xFFDFB6B2),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.tealSand,
    name: 'Teal Sand',
    description: 'Deep blue-green balanced by warm camel neutrals.',
    colors: <Color>[
      Color(0xFF10252A),
      Color(0xFF3D4D55),
      Color(0xFFA79E9C),
      Color(0xFFD3C3B9),
      Color(0xFFB58863),
      Color(0xFF161616),
    ],
    backgroundStart: Color(0xFFB58863),
    backgroundEnd: Color(0xFF10252A),
    surface: Color(0xFFF1E8E2),
    surfaceAlt: Color(0xFFD3C3B9),
    ink: Color(0xFF161616),
    muted: Color(0xFF3D4D55),
    primary: Color(0xFF10252A),
    secondary: Color(0xFFB58863),
    tertiary: Color(0xFFA79E9C),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.forestMist,
    name: 'Forest Mist',
    description: 'Calm forest greens with pale botanical highlights.',
    colors: <Color>[
      Color(0xFF051F20),
      Color(0xFF0B2B26),
      Color(0xFF163832),
      Color(0xFF235347),
      Color(0xFF8EB69B),
      Color(0xFFDAF1DE),
    ],
    backgroundStart: Color(0xFFDAF1DE),
    backgroundEnd: Color(0xFF0B2B26),
    surface: Color(0xFFF4FCF5),
    surfaceAlt: Color(0xFFDAF1DE),
    ink: Color(0xFF051F20),
    muted: Color(0xFF235347),
    primary: Color(0xFF0B2B26),
    secondary: Color(0xFF235347),
    tertiary: Color(0xFF8EB69B),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.burgundyCoffee,
    name: 'Burgundy Coffee',
    description: 'Bold wine tones grounded by creamy coffee neutrals.',
    colors: <Color>[
      Color(0xFF561C24),
      Color(0xFF6D2932),
      Color(0xFFC7B7A3),
      Color(0xFFE8D8C4),
    ],
    backgroundStart: Color(0xFFE8D8C4),
    backgroundEnd: Color(0xFF561C24),
    surface: Color(0xFFFFF8EF),
    surfaceAlt: Color(0xFFE8D8C4),
    ink: Color(0xFF361116),
    muted: Color(0xFF6D2932),
    primary: Color(0xFF6D2932),
    secondary: Color(0xFFC7B7A3),
    tertiary: Color(0xFFE8D8C4),
  ),
  PortfolioPalette(
    id: PortfolioThemeId.roseCocoa,
    name: 'Rose Cocoa',
    description: 'Dusty rose, cocoa, and polished blush surfaces.',
    colors: <Color>[
      Color(0xFF2A0800),
      Color(0xFF775144),
      Color(0xFFC09891),
      Color(0xFFBEA8A7),
      Color(0xFFEAD8D8),
    ],
    backgroundStart: Color(0xFFEAD8D8),
    backgroundEnd: Color(0xFF775144),
    surface: Color(0xFFFFF6F6),
    surfaceAlt: Color(0xFFEAD8D8),
    ink: Color(0xFF2A0800),
    muted: Color(0xFF775144),
    primary: Color(0xFF775144),
    secondary: Color(0xFFC09891),
    tertiary: Color(0xFFBEA8A7),
  ),
];

class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'portfolio_theme_id';

  PortfolioThemeId _themeId = PortfolioThemeId.coralOriginal;

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
