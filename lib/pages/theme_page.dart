import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/theme_controller.dart';
import '../widgets/animated_mesh_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/liquid_gooey.dart';
import 'admin_access.dart';
import 'projects_page.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);

    return AnimatedMeshBackground(
      darkness: 0.32,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Center(
              heightFactor: 1.0,
              child: LiquidGooeyDock(
                currentIndex: 2,
                onTapIndex: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      PremiumPageRoute<void>(page: const ProjectsPage()),
                    );
                  } else if (index == 3) {
                    openProtectedAdmin(context);
                  }
                },
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _ThemeHeader(
                          currentName: controller.palette.name,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 16),
                        GlassSurface(
                          radius: 45,
                          padding: const EdgeInsets.all(26),
                          opacity: 0.10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Choose your portfolio atmosphere',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontSize: 46),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Switch instantly between the original look and the five supplied color palettes. Your selection is remembered on this device.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns = constraints.maxWidth >= 980
                                      ? 3
                                      : constraints.maxWidth >= 620
                                          ? 2
                                          : 1;
                                  final ratio = columns == 1 ? 1.35 : 0.96;

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: portfolioPalettes.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: ratio,
                                    ),
                                    itemBuilder: (context, index) {
                                      final palette =
                                          portfolioPalettes[index];
                                      return _ThemeCard(
                                        palette: palette,
                                        selected:
                                            palette.id == controller.themeId,
                                        onTap: () =>
                                            controller.select(palette.id),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  const _ThemeHeader({
    required this.currentName,
    required this.onBack,
  });

  final String currentName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassSurface(
      radius: 26,
      opacity: 0.08,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: <Widget>[
          IconButton.filled(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'THEME STUDIO',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Current theme: $currentName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.palette_outlined, color: scheme.primary),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatefulWidget {
  const _ThemeCard({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final PortfolioPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.012 : 1,
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 520),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface.withOpacity(0.93),
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.ink.withOpacity(_hovered ? 0.20 : 0.12),
                  blurRadius: _hovered ? 34 : 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          palette.backgroundStart,
                          palette.backgroundEnd,
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: palette.colors
                            .map(
                              (color) => Expanded(
                                child: Container(
                                  height: 74 +
                                      palette.colors.indexOf(color) * 7,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        palette.name,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 420),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? palette.primary
                            : palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.selected ? 'ACTIVE' : 'USE',
                        style: TextStyle(
                          color: widget.selected
                              ? Colors.white
                              : palette.ink,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  palette.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
