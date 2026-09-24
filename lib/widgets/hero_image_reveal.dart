import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Layered hero artwork panel: three stacked plates revealed progressively
/// under the cursor. Layer order (bottom → top): sand splatter plate, red
/// collage plate, blue snow plate (top). The blue plate shows by default;
/// moving the cursor carves a soft circular hole through it that reveals the
/// red plate beneath, and a smaller hole through the red plate reveals the
/// deepest sand plate.
///
/// Desktop: mouse hover drives the reveal (smooth lerped follow).
/// Touch: a horizontal drag reveals without breaking vertical page scroll.
/// Before the first interaction a slow autonomous drift plays as an attractor.
/// If any plate asset is missing, the panel renders a flat neutral plate and
/// stays completely inert (no interaction, no overlays).
class HeroImageReveal extends StatefulWidget {
  const HeroImageReveal({super.key});

  @override
  State<HeroImageReveal> createState() => _HeroImageRevealState();
}

class _HeroImageRevealState extends State<HeroImageReveal>
    with SingleTickerProviderStateMixin {
  /// Asset paths, bottom → top. Ship files here and register them in
  /// pubspec.yaml to activate the layered reveal.
  static const List<String> _assetPaths = <String>[
    'assets/images/hero/hero_sand.png',
    'assets/images/hero/hero_red.png',
    'assets/images/hero/hero_blue.png',
  ];

  final List<ui.Image?> _layers = <ui.Image?>[null, null, null];
  final Stopwatch _clock = Stopwatch()..start();

  late final Ticker _ticker;
  Size _size = Size.zero;
  Offset? _center;
  Offset? _targetCenter;
  double _reveal = 0;
  double _targetReveal = 0;
  Duration _lastMove = Duration.zero;
  bool _everInteracted = false;
  bool _unavailable = false;
  bool _loaded = false;

  double get _maxReveal {
    final diagonal = math.sqrt(
      _size.width * _size.width + _size.height * _size.height,
    );
    return diagonal * 0.72;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _loadImages();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    for (var i = 0; i < _assetPaths.length; i++) {
      try {
        final data = await rootBundle.load(_assetPaths[i]);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        if (!mounted) return;
        setState(() => _layers[i] = frame.image);
      } catch (_) {
        if (!mounted) return;
        setState(() => _unavailable = true);
        return;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  void _tick(Duration elapsed) {
    if (!mounted || _unavailable) return;

    if (!_everInteracted && _loaded) {
      // Autonomous attractor drift until the visitor first interacts.
      final t = _clock.elapsedMicroseconds / 1e6;
      _targetCenter = Offset(
        _size.width * (0.5 + 0.30 * math.sin(t * 0.55)),
        _size.height * (0.42 + 0.30 * math.cos(t * 0.42)),
      );
      _center ??= _targetCenter;
      _targetReveal = _maxReveal * (0.55 + 0.38 * math.sin(t * 0.33));
    } else if (_clock.elapsed - _lastMove > const Duration(milliseconds: 2600)) {
      // Idle: gently heal the reveal back to the untouched blue plate.
      _targetReveal = ui.lerpDouble(_targetReveal, 0, 0.035)!;
    }

    _center = _center == null
        ? _targetCenter
        : Offset.lerp(_center, _targetCenter, 0.22);
    _reveal = ui.lerpDouble(_reveal, _targetReveal, 0.16)!;
    setState(() {});
  }

  void _pointTo(Offset local, double growth) {
    _everInteracted = true;
    _targetCenter = local;
    _center ??= local;
    _targetReveal = (_targetReveal + growth + 8).clamp(0.0, _maxReveal);
    _lastMove = _clock.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _unavailable
              ? const _FallbackPlate()
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _HeroRevealPainter(
                          layers: _layers,
                          center: _center,
                          reveal: _reveal,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: MouseRegion(
                        opaque: false,
                        cursor: SystemMouseCursors.precise,
                        onHover: (event) => _pointTo(
                          event.localPosition,
                          event.delta.distance * 1.7,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) =>
                            _pointTo(details.localPosition, _maxReveal * 0.18),
                        // Horizontal drags reveal; vertical swipes keep
                        // scrolling the page (mobile-safe).
                        onHorizontalDragUpdate: (details) => _pointTo(
                          details.localPosition,
                          details.delta.distance * 1.7,
                        ),
                      ),
                    ),
                    if (constraints.maxWidth >= 560)
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: IgnorePointer(
                          child: Center(
                            child: Text(
                              'MOVE TO REVEAL',
                              style: TextStyle(
                                color: Color(0x99FFFFFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

/// Paints the three plates: full sand base, red masked by the small reveal
/// circle, blue masked by the large reveal circle (soft radial holes).
class _HeroRevealPainter extends CustomPainter {
  _HeroRevealPainter({
    required this.layers,
    required this.center,
    required this.reveal,
  });

  /// [sand, red, blue] — bottom → top.
  final List<ui.Image?> layers;
  final Offset? center;
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    _paintFull(canvas, rect, layers[0]);

    if (center != null && reveal > 1) {
      _paintMasked(canvas, rect, layers[1], center!, reveal * 0.55);
      _paintMasked(canvas, rect, layers[2], center!, reveal);
    } else {
      _paintFull(canvas, rect, layers[2]);
    }
  }

  void _paintFull(Canvas canvas, Rect rect, ui.Image? image) {
    if (image == null) return;
    paintImage(
      canvas: canvas,
      rect: rect,
      image: image,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }

  void _paintMasked(
    Canvas canvas,
    Rect rect,
    ui.Image? image,
    Offset hole,
    double holeRadius,
  ) {
    if (image == null) return;

    canvas.saveLayer(null, Paint());
    _paintFull(canvas, rect, image);

    final mask = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.radial(
        hole,
        holeRadius,
        const <Color>[
          Color(0x00000000),
          Color(0x00000000),
          Color(0xFFFFFFFF),
        ],
        const <double>[0.0, 0.55, 1.0],
      );
    canvas.drawRect(rect, mask);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeroRevealPainter oldDelegate) => true;
}

/// Flat neutral plate shown until the hero plate assets ship.
class _FallbackPlate extends StatelessWidget {
  const _FallbackPlate();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFD9DDE5),
            Color(0xFFEFF1F5),
            Color(0xFFDDE2EA),
          ],
        ),
      ),
    );
  }
}
