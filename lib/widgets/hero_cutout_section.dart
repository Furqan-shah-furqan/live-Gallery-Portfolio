import 'package:flutter/material.dart';

import '../core/aura_bento.dart';
import 'glass_surface.dart';
import 'hero_image_reveal.dart';

/// Aura-Bento hero: a large white squircle module (radius-xl) floating on the
/// aura canvas, pairing a serif conversational headline with sans interface
/// chrome, a black action anchor, and a layered cursor-reveal artwork panel.
class HeroCutoutLayout extends StatefulWidget {
  const HeroCutoutLayout({
    super.key,
    required this.projectCount,
    required this.role,
    required this.onProjects,
    required this.onAdmin,
    required this.scrollController,
    this.onThemes,
  });

  final int projectCount;
  final String role;
  final VoidCallback onProjects;
  final VoidCallback onAdmin;
  final ScrollController scrollController;
  final VoidCallback? onThemes;

  @override
  State<HeroCutoutLayout> createState() => _HeroCutoutLayoutState();
}

class _HeroCutoutLayoutState extends State<HeroCutoutLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1040;

        return Container(
          decoration: BoxDecoration(
            color: AuraBento.surfaceWhite,
            borderRadius: BorderRadius.circular(AuraBento.radiusXl),
            boxShadow: AuraBento.ambientLg(const Color(0xFF111827)),
          ),
          padding: EdgeInsets.all(isDesktop ? 14 : 10),
          child: SizedBox(
            height: isDesktop ? 580 : 500,
            child: ClipRRect(
            borderRadius: BorderRadius.circular(
                AuraBento.innerRadius(AuraBento.radiusXl, 14)),
            child: Stack(
              children: <Widget>[
                // Inner aura wash inside the hero card (mesh-card equivalent).
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            const Color(0x66FFC896),
                            Colors.white.withAlpha(0),
                            const Color(0x59B4BEFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Layered cursor-reveal artwork panel (desktop hover + touch
                // drag; renders a flat plate until the hero assets ship).
                const Positioned.fill(
                  child: HeroImageReveal(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? AuraBento.space8 : AuraBento.space5,
                    isDesktop ? AuraBento.space8 : AuraBento.space6,
                    isDesktop ? AuraBento.space8 : AuraBento.space5,
                    isDesktop ? AuraBento.space8 : AuraBento.space6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _HeroTopBar(
                        onProjects: widget.onProjects,
                        onAdmin: widget.onAdmin,
                        projectCount: widget.projectCount,
                      ),
                      // Vertically centered copy block between the top bar
                      // and the bottom of the hero module.
                      const Spacer(flex: 4),
                      _HeroCopy(
                        role: widget.role,
                        projectCount: widget.projectCount,
                        onProjects: widget.onProjects,
                        onAdmin: widget.onAdmin,
                        isDesktop: isDesktop,
                      ),
                      const Spacer(flex: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}

class _HeroTopBar extends StatelessWidget {
  const _HeroTopBar({
    required this.onProjects,
    required this.onAdmin,
    required this.projectCount,
  });

  final VoidCallback onProjects;
  final VoidCallback onAdmin;
  final int projectCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Circular monogram token (§4.2 pitch black variant).
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AuraBento.accentDarkAction,
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                color: AuraBento.textInverted,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: AuraBento.fontSerif,
              ),
            ),
          ),
        ),
        const SizedBox(width: AuraBento.space3),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Live Systems Gallery',
              style: TextStyle(
                color: AuraBento.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Aura-Bento portfolio',
              style: TextStyle(
                color: AuraBento.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Search capsule (§4.1 compact) — desktop only.
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 620) return const SizedBox.shrink();
            return Container(
              width: 210,
              height: AuraBento.inputHeightCompact,
              padding: const EdgeInsets.symmetric(horizontal: AuraBento.space4),
              decoration: BoxDecoration(
                color: AuraBento.canvasLightSecondary,
                borderRadius: BorderRadius.circular(AuraBento.radiusFull),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.search_rounded,
                      color: AuraBento.textTertiary, size: 17),
                  const SizedBox(width: AuraBento.space2),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        color: AuraBento.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search projects…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => onProjects(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: AuraBento.space2),
        AuraCircularToken(
          icon: Icons.photo_library_rounded,
          variant: AuraCircularTokenVariant.pureWhite,
          tooltip: 'Gallery Viewer (All Projects)',
          onTap: onProjects,
        ),
        const SizedBox(width: AuraBento.space2),
        AuraCircularToken(
          icon: Icons.admin_panel_settings_rounded,
          tooltip: 'Admin Control',
          onTap: onAdmin,
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.role,
    required this.projectCount,
    required this.onProjects,
    required this.onAdmin,
    required this.isDesktop,
  });

  final String role;
  final int projectCount;
  final VoidCallback onProjects;
  final VoidCallback onAdmin;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AuraBadge(
          text: 'AUTONOMOUS FLUTTER INTERFACES',
          icon: Icons.bolt_rounded,
          variant: AuraBadgeVariant.amber,
        ),
        const SizedBox(height: AuraBento.space4),
        // §2.2 conversational query in the serif display face.
        Text(
          'Live systems,\nbuilt and shipped.',
          style: TextStyle(
            fontFamily: AuraBento.fontSerif,
            color: AuraBento.textPrimary,
            fontSize: isDesktop ? 62 : 42,
            height: 1.02,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AuraBento.space3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            role,
            style: const TextStyle(
              color: AuraBento.textSecondary,
              fontSize: 15,
              height: 22 / 15,
            ),
          ),
        ),
        const SizedBox(height: AuraBento.space5),
        Wrap(
          spacing: AuraBento.space3,
          runSpacing: AuraBento.space2,
          children: <Widget>[
            PremiumButton(
              label: 'Explore Live Work',
              icon: Icons.arrow_outward_rounded,
              primary: true,
              onPressed: onProjects,
            ),
            PremiumButton(
              label: 'Admin Control',
              icon: Icons.lock_open_rounded,
              onPressed: onAdmin,
            ),
          ],
        ),
      ],
    );
  }
}

/// §4.5 Dark HUD live tracker embedded at the bottom of the hero module.
