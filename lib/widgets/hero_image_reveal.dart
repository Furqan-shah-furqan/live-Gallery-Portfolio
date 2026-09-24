import 'dart:async';
import 'dart:convert';
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
  /// Layered hero plates live in `assets/images/hero/`. Any three images
  /// dropped into that folder activate the reveal — no code change needed.
  /// Files are classified by filename keywords (blue/snow → top, red →
  /// middle, everything else → base); ties fall back to alphabetical order.
  static const String _heroAssetDir = 'assets/images/hero/';
  static final RegExp _imageExt = RegExp(r'\.(png|jpg|jpeg|webp)$');

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
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final assets = jsonDecode(manifest) as Map<String, dynamic>;
      final paths = assets.keys
          .where((path) =>
              path.startsWith(_heroAssetDir) && _imageExt.hasMatch(path))
          .toList()
        ..sort(_comparePlateOrder);

      if (paths.length < 3) {
        if (mounted) setState(() => _unavailable = true);
        return;
      }

      for (var i = 0; i < 3; i++) {
        final data = await rootBundle.load(paths[i]);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        if (!mounted) return;
        setState(() => _layers[i] = frame.image);
      }
      if (mounted) setState(() => _loaded = true);
    } catch (_) {
      if (mounted) setState(() => _unavailable = true);
    }
  }

  /// Sort order bottom → top: base tier (no keyword) → red tier → blue tier.
  int _comparePlateOrder(String a, String b) {
    final tierA = _plateTier(a);
    final tierB = _plateTier(b);
    if (tierA != tierB) return tierA.compareTo(tierB);
    return a.compareTo(b);
  }

  int _plateTier(String path) {
    final name = path.toLowerCase();
    if (name.contains('blue') || name.contains('snow')) return 2;
    if (name.contains('red')) return 1;
    return 0;
  }

  void _tick(Duration elapsed) {
    if (!mounted || _unavailable) return;

    if (!_everInteracted && _loaded) {
      // Autonomous attractor drift until the visitor first interacts —
      // capped so idle mobile devices are not painting forever.
      final t = _clock.elapsedMicroseconds / 1e6;
      if (t < 12) {
        _targetCenter = Offset(
          _size.width * (0.5 + 0.30 * math.sin(t * 0.55)),
          _size.height * (0.42 + 0.30 * math.cos(t * 0.42)),
        );
        _center ??= _targetCenter;
        _targetReveal = _maxReveal * (0.55 + 0.38 * math.sin(t * 0.33));
      }
    } else if (_clock.elapsed - _lastMove > const Duration(milliseconds: 2600)) {
      // Idle: heal the reveal back to the untouched blue plate and relax
      // the kinetic grid by easing the cursor influence off-panel.
      _targetReveal = ui.lerpDouble(_targetReveal, 0, 0.035)!;
      _targetCenter = Offset(
        _size.width + 200,
        _size.height + 200,
      );
    }

    final nextCenter = _center == null
        ? _targetCenter
        : Offset.lerp(_center, _targetCenter, 0.22);
    final nextReveal = ui.lerpDouble(_reveal, _targetReveal, 0.16)!;

    // CPU idle guard: once fully settled, stop repainting every frame.
    final c0 = _center;
    final c1 = nextCenter;
    final double centerDelta;
    if (c0 == null || c1 == null) {
      centerDelta = 1.0;
    } else {
      centerDelta = (c1 - c0).distance;
    }
    final revealDelta = (nextReveal - _reveal).abs();
    if (!_everInteracted || centerDelta > 0.4 || revealDelta > 0.4) {
      setState(() {
        _center = nextCenter;
        _reveal = nextReveal;
      });
    }
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
          child: Semantics(
            label: 'Hero layered artwork with kinetic grid reveal',
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
                    // Kinetic cursor grid: a warped mesh that displaces away
                    // from the cursor, bending over the layered plates.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _KineticGridPainter(cursor: _center),
                          ),
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
          ),
        );
      },
    );
  }
}

/// Kinetic mesh overlay: thin grid lines whose vertices are displaced away
/// from the cursor with a smooth radial falloff. Single 1px-stroke path per
/// frame — GPU friendly, no blur, no glow, confined to the hero panel.
class _KineticGridPainter extends CustomPainter {
  _KineticGridPainter({required this.cursor});

  final Offset? cursor;

  static const double _cell = 26.0;
  static const double _radius = 150.0;
  static const double _strength = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A121417)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Offset warp(Offset p) {
      final c = cursor;
      if (c == null) return p;
      final v = p - c;
      final d = v.distance;
      if (d >= _radius || d < 0.001) return p;
      final falloff = math.pow(1 - d / _radius, 1.6).toDouble();
      return p + (v / d) * (falloff * _strength);
    }

    final path = Path();

    // Vertical strands.
    for (double x = 0; x <= size.width + _cell; x += _cell) {
      final cx = math.min(x, size.width);
      path.moveTo(cx, 0);
      for (double y = _cell; y <= size.height + _cell; y += _cell) {
        path.lineTo(warp(Offset(cx, math.min(y, size.height))).dx,
            warp(Offset(cx, math.min(y, size.height))).dy);
      }
    }

    // Horizontal strands.
    for (double y = 0; y <= size.height + _cell; y += _cell) {
      final cy = math.min(y, size.height);
      path.moveTo(0, cy);
      for (double x = _cell; x <= size.width + _cell; x += _cell) {
        final p = warp(Offset(math.min(x, size.width), cy));
        path.lineTo(p.dx, p.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KineticGridPainter oldDelegate) =>
      oldDelegate.cursor != cursor;
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
