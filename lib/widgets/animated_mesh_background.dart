import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({
    super.key,
    required this.child,
    this.darkness = 0.16,
    this.scrollController,
  });

  final Widget child;

  /// Controls the strength of the translucent veil over the mesh.
  final double darkness;

  /// Optional scroll controller to dynamically morph colors and orbs on scroll.
  final ScrollController? scrollController;

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Listenable animationListenable = widget.scrollController != null
        ? Listenable.merge(<Listenable>[_controller, widget.scrollController!])
        : _controller;

    return ColoredBox(
      color: const Color(0xFF070811),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: animationListenable,
              builder: (context, _) {
                final scrollOffset = (widget.scrollController?.hasClients == true)
                    ? widget.scrollController!.offset
                    : 0.0;
                final scrollProgress = (scrollOffset / 850.0).clamp(0.0, 1.0);

                return CustomPaint(
                  painter: _ScrollAwareMeshPainter(
                    timeProgress: _controller.value,
                    scrollProgress: scrollProgress,
                    scrollOffset: scrollOffset,
                    veilStrength: widget.darkness,
                    colorScheme: scheme,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.05),
                      scheme.surface.withValues(alpha: 0.02),
                      scheme.primary.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _ScrollAwareMeshPainter extends CustomPainter {
  _ScrollAwareMeshPainter({
    required this.timeProgress,
    required this.scrollProgress,
    required this.scrollOffset,
    required this.veilStrength,
    required this.colorScheme,
  });

  final double timeProgress;
  final double scrollProgress;
  final double scrollOffset;
  final double veilStrength;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final t = timeProgress * math.pi * 2;
    final minSide = math.min(size.width, size.height);

    // Scroll-morphing palette:
    // Scroll 0.0 (Hero Top): Cosmic cyberpunk indigo/navy with electric accents
    // Scroll 0.5 (Live Systems): Chromatic dusk with luminous coral & neon cyan
    // Scroll 1.0 (Contact/Footer): Deep midnight obsidian with rich ruby/ultraviolet
    final Color topColor = Color.lerp(
      const Color(0xFF070914),
      Color.lerp(const Color(0xFF140F22), const Color(0xFF080710), (scrollProgress - 0.5).clamp(0.0, 0.5) * 2)!,
      (scrollProgress * 2).clamp(0.0, 1.0),
    )!;

    final Color midColor1 = Color.lerp(
      const Color(0xFF0D122B),
      Color.lerp(const Color(0xFF261435), const Color(0xFF1A0C22), (scrollProgress - 0.5).clamp(0.0, 0.5) * 2)!,
      (scrollProgress * 2).clamp(0.0, 1.0),
    )!;

    final Color midColor2 = Color.lerp(
      const Color(0xFF19183B),
      Color.lerp(const Color(0xFF331A3E), const Color(0xFF230F26), (scrollProgress - 0.5).clamp(0.0, 0.5) * 2)!,
      (scrollProgress * 2).clamp(0.0, 1.0),
    )!;

    final Color bottomColor = Color.lerp(
      const Color(0xFF101934),
      Color.lerp(const Color(0xFF1D2246), const Color(0xFF0B0914), (scrollProgress - 0.5).clamp(0.0, 0.5) * 2)!,
      (scrollProgress * 2).clamp(0.0, 1.0),
    )!;

    // Blend base colors with active Theme ColorScheme for seamless theme reactivity
    final blendedTop = Color.lerp(topColor, colorScheme.primaryContainer, 0.35)!;
    final blendedMid1 = Color.lerp(midColor1, colorScheme.secondaryContainer, 0.30)!;
    final blendedMid2 = Color.lerp(midColor2, colorScheme.tertiary, 0.28)!;
    final blendedBottom = Color.lerp(bottomColor, colorScheme.surface, 0.32)!;

    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-0.2 + 0.4 * math.sin(t * 0.2), -1.0),
        end: Alignment(0.2 + 0.4 * math.cos(t * 0.2), 1.0),
        colors: <Color>[
          blendedTop,
          blendedMid1,
          blendedMid2,
          blendedBottom,
        ],
        stops: const <double>[0.0, 0.32, 0.68, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    // Dynamic Orbs with both perpetual floating animation AND scroll parallax translation:
    final parallax1 = scrollOffset * 0.14;
    final parallax2 = scrollOffset * 0.20;
    final parallax3 = -scrollOffset * 0.10;
    final parallax4 = -scrollOffset * 0.18;
    final parallax5 = -scrollOffset * 0.12;

    // Dynamic orb color highlights that shift based on scroll
    final Color orb1Highlight = Color.lerp(
      const Color(0xFF00F0FF),
      const Color(0xFFFA558F),
      scrollProgress,
    )!;
    final Color orb2Highlight = Color.lerp(
      const Color(0xFFA855F7),
      const Color(0xFFFF9B67),
      scrollProgress,
    )!;
    final Color orb4Highlight = Color.lerp(
      const Color(0xFFFF4D79),
      const Color(0xFF00E5FF),
      scrollProgress,
    )!;

    final orbs = <_Orb>[
      // Orb 1: Top-Left Ambient Cyan/Magenta
      _Orb(
        center: Offset(
          size.width * (0.16 + math.sin(t * 0.55) * 0.045),
          size.height * (0.12 + math.cos(t * 0.43) * 0.045) + parallax1,
        ),
        radius: minSide * (0.44 + scrollProgress * 0.08),
        colors: <Color>[
          orb1Highlight.withValues(alpha: 0.38),
          colorScheme.tertiaryContainer.withValues(alpha: 0.20),
          Colors.transparent,
        ],
      ),
      // Orb 2: Top-Right Violet/Amber
      _Orb(
        center: Offset(
          size.width * (0.82 + math.cos(t * 0.48) * 0.052),
          size.height * (0.18 + math.sin(t * 0.61) * 0.050) + parallax2,
        ),
        radius: minSide * 0.42,
        colors: <Color>[
          orb2Highlight.withValues(alpha: 0.36),
          colorScheme.surface.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ),
      // Orb 3: Center Core Glow
      _Orb(
        center: Offset(
          size.width * (0.50 + math.sin(t * 0.38) * 0.08),
          size.height * (0.48 + math.cos(t * 0.52) * 0.065) + parallax3,
        ),
        radius: minSide * (0.38 + scrollProgress * 0.12),
        colors: <Color>[
          colorScheme.secondary.withValues(alpha: 0.35),
          colorScheme.primary.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ),
      // Orb 4: Bottom-Right Coral/Electric Cyan
      _Orb(
        center: Offset(
          size.width * (0.78 + math.sin(t * 0.51) * 0.065),
          size.height * (0.84 + math.cos(t * 0.46) * 0.055) + parallax4,
        ),
        radius: minSide * 0.48,
        colors: <Color>[
          orb4Highlight.withValues(alpha: 0.40),
          colorScheme.secondaryContainer.withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ),
      // Orb 5: Bottom-Left Deep Ruby/Violet
      _Orb(
        center: Offset(
          size.width * (0.18 + math.cos(t * 0.42) * 0.055),
          size.height * (0.82 + math.sin(t * 0.58) * 0.050) + parallax5,
        ),
        radius: minSide * 0.36,
        colors: <Color>[
          const Color(0xFFE11D48).withValues(alpha: 0.30),
          colorScheme.tertiary.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ),
    ];

    for (final orb in orbs) {
      final rect = Rect.fromCircle(center: orb.center, radius: orb.radius);
      final paint = Paint()
        ..shader = RadialGradient(colors: orb.colors).createShader(rect);
      canvas.drawCircle(orb.center, orb.radius, paint);
    }

    final veilOpacity = (veilStrength * 0.08).clamp(0.01, 0.06).toDouble();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: veilOpacity),
    );
  }

  @override
  bool shouldRepaint(covariant _ScrollAwareMeshPainter oldDelegate) {
    return oldDelegate.timeProgress != timeProgress ||
        oldDelegate.scrollProgress != scrollProgress ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.veilStrength != veilStrength ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class _Orb {
  const _Orb({
    required this.center,
    required this.radius,
    required this.colors,
  });

  final Offset center;
  final double radius;
  final List<Color> colors;
}

