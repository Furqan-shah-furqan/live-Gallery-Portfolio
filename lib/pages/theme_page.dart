import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
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
                padding:
                    const EdgeInsets.fromLTRB(20, 14, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        _ThemeHeader(
                          currentName: controller.palette.name,
                          onBack: () =>
                              Navigator.of(context).pop(),
                        ),
                        const SizedBox(
                            height: AuraBento.space4),
                        GlassSurface(
                          radius: AuraBento.radiusXl,
                          padding: const EdgeInsets.all(
                              AuraBento.space6 + 2),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: <Widget>[
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide =
                                      constraints.maxWidth >= 600;
                                  return Text(
                                    'Choose your portfolio atmosphere',
                                    style: TextStyle(
                                      fontFamily:
                                          AuraBento.fontSerif,
                                      color: AuraBento.textPrimary,
                                      fontSize: wide ? 40 : 32,
                                      height: 1.08,
                                      letterSpacing: -0.4,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                  height: AuraBento.space3),
                              Text(
                                'Switch instantly between six Aura-Bento atmospheres. Every theme keeps the same neutral canvas, white bento surfaces, and accessible anchors — only the aura changes.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),
                              const SizedBox(
                                  height: AuraBento.space6),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns =
                                      constraints.maxWidth >= 980
                                          ? 3
                                          : constraints.maxWidth >= 620
                                              ? 2
                                              : 1;
                                  final ratio = columns == 1
                                      ? 1.35
                                      : 0.96;

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        portfolioPalettes.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing:
                                          AuraBento.space4,
                                      mainAxisSpacing:
                                          AuraBento.space4,
                                      childAspectRatio: ratio,
                                    ),
                                    itemBuilder: (context, index) {
                                      final palette =
                                          portfolioPalettes[index];
                                      return _ThemeCard(
                                        palette: palette,
                                        selected: palette.id ==
                                            controller.themeId,
                                        onTap: () => controller
                                            .select(palette.id),
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
    return GlassSurface(
      radius: AuraBento.radiusMd + 6,
      padding: const EdgeInsets.symmetric(
        horizontal: AuraBento.space4,
        vertical: AuraBento.space3 - 1,
      ),
      child: Row(
        children: <Widget>[
          AuraCircularToken(
            icon: Icons.arrow_back_rounded,
            variant: AuraCircularTokenVariant.pitchBlack,
            tooltip: 'Back',
            onTap: onBack,
          ),
          const SizedBox(width: AuraBento.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'THEME STUDIO',
                  style: TextStyle(
                    color: AuraBento.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Current theme: $currentName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AuraBento.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.palette_outlined,
            color: AuraBento.accentBlueAction,
          ),
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
            padding: const EdgeInsets.all(AuraBento.space3),
            decoration: BoxDecoration(
              color: AuraBento.surfaceWhite,
              borderRadius:
                  BorderRadius.circular(AuraBento.radiusLg),
              border: widget.selected
                  ? Border.all(
                      color: palette.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: AuraBento.ambientMd(
                const Color(0xFF111827),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                        AuraBento.space4 + 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AuraBento.innerRadius(
                            AuraBento.radiusLg, AuraBento.space3),
                      ),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: palette.colors
                            .map(
                              (color) => Expanded(
                                child: Container(
                                  height: 74 +
                                      palette.colors
                                              .indexOf(color) *
                                          7,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius:
                                        const BorderRadius
                                            .vertical(
                                      top: Radius.circular(8),
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
                const SizedBox(height: AuraBento.space3 + 2),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        palette.name,
                        style: const TextStyle(
                          color: AuraBento.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 420),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? AuraBento.accentDarkAction
                            : AuraBento.badgeNeutralBg,
                        borderRadius: BorderRadius.circular(
                            AuraBento.radiusFull),
                      ),
                      child: Text(
                        widget.selected ? 'ACTIVE' : 'USE',
                        style: TextStyle(
                          color: widget.selected
                              ? AuraBento.textInverted
                              : AuraBento.badgeNeutralText,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
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
                  style: const TextStyle(
                    color: AuraBento.textSecondary,
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
