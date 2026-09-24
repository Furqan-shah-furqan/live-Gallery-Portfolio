import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/aura_bento.dart';
import '../core/theme_controller.dart';

/// Aura-Bento background canvas (§2.1, z-canvas → z-aura layering).
///
/// Light neutral base (#E9EBEF) with two soft chromatic aura patches
/// (warm + cool, derived from the active palette) drifting slowly behind
/// the bento cards. Blurred, low opacity, and pointer-transparent.
class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({
    super.key,
    required this.child,
    this.darkness = 0.16,
    this.scrollController,
  });

  final Widget child;

  /// Kept for call-site compatibility; the aura canvas is light-only.
  final double darkness;

  /// Optional scroll controller for subtle aura parallax.
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
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ThemeControllerScope.of(context).palette;
    final Listenable animationListenable = widget.scrollController != null
        ? Listenable.merge(<Listenable>[_controller, widget.scrollController!])
        : _controller;

    return ColoredBox(
      color: AuraBento.canvasLight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: animationListenable,
              builder: (context, _) {
                final scrollOffset =
                    (widget.scrollController?.hasClients == true)
                        ? widget.scrollController!.offset
                        : 0.0;
                final scrollProgress = (scrollOffset / 900.0).clamp(0.0, 1.0);

                return CustomPaint(
                  painter: _AuraMeshPainter(
                    timeProgress: _controller.value,
                    scrollProgress: scrollProgress,
                    scrollOffset: scrollOffset,
                    palette: palette,
                  ),
                );
              },
            ),
          ),
          // Soft vignette to keep card edges crisp against the aura.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withAlpha(8),
                      Colors.transparent,
                      const Color(0xFF111827).withAlpha(5),
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

class _AuraMeshPainter extends CustomPainter {
  _AuraMeshPainter({
    required this.timeProgress,
    required this.scrollProgress,
    required this.scrollOffset,
    required this.palette,
  });

  final double timeProgress;
  final double scrollProgress;
  final double scrollOffset;
  final PortfolioPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final t = timeProgress * math.pi * 2;
    final minSide = math.min(size.width, size.height);

    // Aura patches (z-aura): warm tone top-left, cool tone bottom-right,
    // drifting on slow sine orbits with a gentle scroll parallax.
    final parallax = scrollOffset * 0.10;

    final warmCenter = Offset(
      size.width * (0.12 + math.sin(t * 0.45) * 0.05),
      size.height * (0.10 + math.cos(t * 0.38) * 0.05) + parallax,
    );
    final coolCenter = Offset(
      size.width * (0.88 + math.cos(t * 0.40) * 0.05),
      size.height * (0.92 + math.sin(t * 0.52) * 0.05) - parallax,
    );
    final midCenter = Offset(
      size.width * (0.55 + math.sin(t * 0.30) * 0.08),
      size.height * (0.45 + math.cos(t * 0.34) * 0.07),
    );

    final warm = palette.backgroundStart;
    final cool = palette.backgroundEnd;
    final accent = palette.primary;

    // Large soft warm wash (≈ mesh-ambient first stop).
    _drawAura(canvas, warmCenter, minSide * (0.62 + scrollProgress * 0.10),
        warm.withAlpha(165));
    // Large soft cool wash (≈ mesh-ambient second stop).
    _drawAura(canvas, coolCenter, minSide * (0.60 + scrollProgress * 0.10),
        cool.withAlpha(175));
    // Faint accent bloom bridging the two.
    _drawAura(canvas, midCenter, minSide * 0.48, accent.withAlpha(56));

    // Grain-free highlight: a whisper of pure white at the very top so white
    // cards read as floating above the aura rather than blending into it.
    _drawAura(
      canvas,
      Offset(size.width * 0.5, -size.height * 0.15),
      minSide * 0.55,
      Colors.white.withAlpha(120),
    );
  }

  void _drawAura(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[color, color.withAlpha(0)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuraMeshPainter oldDelegate) {
    return oldDelegate.timeProgress != timeProgress ||
        oldDelegate.scrollProgress != scrollProgress ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.palette != palette;
  }
}
