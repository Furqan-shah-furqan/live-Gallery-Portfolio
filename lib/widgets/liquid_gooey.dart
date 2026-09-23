import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Available liquid gooey visual and interaction effects
enum LiquidEffect {
  melt,
  pull,
  morph,
  float,
}

/// A premium, high-performance Flutter widget that replicates the
/// `liquid-gooey` React library's molten fluid / metaball merging effect.
///
/// It coordinates gooey liquid bridges between child [LiquidItem] elements,
/// allowing them to melt, stretch, and fuse together while keeping their
/// inner children (images, text, icons) crisp and sharp.
class Liquid extends StatefulWidget {
  const Liquid({
    super.key,
    required this.children,
    this.effect = LiquidEffect.melt,
    this.meltDistance = 180.0,
    this.fluidColor,
    this.glowColor,
    this.interactive = true,
    this.width,
    this.height = 200,
  });

  /// The child items to participate in the liquid gooey simulation.
  final List<LiquidItem> children;

  /// The primary liquid gooey effect mode.
  final LiquidEffect effect;

  /// Maximum distance at which two items begin to melt together.
  final double meltDistance;

  /// Custom liquid color. If null, adapts to theme primary/secondary.
  final Color? fluidColor;

  /// Custom glow color for the liquid aura.
  final Color? glowColor;

  /// Whether items can be interactively dragged and pulled.
  final bool interactive;

  final double? width;
  final double height;

  @override
  State<Liquid> createState() => _LiquidState();
}

class _LiquidState extends State<Liquid> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final Map<int, Offset> _positions = <int, Offset>{};
  final Map<int, Offset> _basePositions = <int, Offset>{};
  int? _activeDragIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _ensurePositions(Size size) {
    if (widget.children.isEmpty) return;
    final n = widget.children.length;
    final itemSize = widget.children.first.size;
    // Position items adjacent to each other so they visibly melt by default
    final clusterGap = (itemSize + 22.0).clamp(60.0, 120.0);
    final totalClusterWidth = (n - 1) * clusterGap;
    final startX = (size.width - totalClusterWidth) / 2;

    for (int i = 0; i < n; i++) {
      if (!_basePositions.containsKey(i)) {
        final defaultPos = widget.children[i].initialOffset ??
            Offset(startX + i * clusterGap, size.height / 2);
        _basePositions[i] = defaultPos;
        _positions[i] = defaultPos;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fluid = widget.fluidColor ?? scheme.primary.withOpacity(0.42);
    final glow = widget.glowColor ?? scheme.secondary.withOpacity(0.28);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height;
        final size = Size(w, h);
        _ensurePositions(size);

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            // Collect circles for metaball gooey painter
            final circles = <_MetaballCircle>[];
            final n = widget.children.length;

            for (int i = 0; i < n; i++) {
              final item = widget.children[i];
              Offset pos = _positions[i] ?? Offset(w / 2, h / 2);

              // Add subtle organic liquid float breathing if not being dragged
              if (_activeDragIndex != i && widget.effect == LiquidEffect.melt) {
                final breath = math.sin(_pulseController.value * math.pi * 2 + i) * 3.5;
                final breathX = math.cos(_pulseController.value * math.pi * 2 + i * 1.5) * 2.0;
                pos = Offset(pos.dx + breathX, pos.dy + breath);
              }

              final itemRadius = item.size / 2 + 10; // Gooey outer boundary
              circles.add(_MetaballCircle(
                center: pos,
                radius: itemRadius,
                color: item.fluidColor ?? fluid,
              ));
            }

            return SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // 1. Gooey liquid metaball bridge layer (connecting items)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LiquidMetaballPainter(
                        circles: circles,
                        meltDistance: widget.meltDistance,
                        defaultColor: fluid,
                        glowColor: glow,
                        pulse: _pulseController.value,
                        effect: widget.effect,
                      ),
                    ),
                  ),

                  // 2. Crisp child items rendered on top at their positions
                  for (int i = 0; i < n; i++)
                    _buildPositionedItem(i, widget.children[i], size),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPositionedItem(int index, LiquidItem item, Size containerSize) {
    final pos = _positions[index] ?? Offset(containerSize.width / 2, containerSize.height / 2);
    final halfSize = item.size / 2;

    Widget itemWidget = item;

    if (widget.interactive && item.draggable) {
      itemWidget = MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: GestureDetector(
          onPanStart: (_) {
            setState(() => _activeDragIndex = index);
          },
          onPanUpdate: (details) {
            setState(() {
              final current = _positions[index] ?? pos;
              final nextX = (current.dx + details.delta.dx)
                  .clamp(halfSize, containerSize.width - halfSize);
              final nextY = (current.dy + details.delta.dy)
                  .clamp(halfSize, containerSize.height - halfSize);
              _positions[index] = Offset(nextX, nextY);
            });
          },
          onPanEnd: (_) {
            setState(() {
              _activeDragIndex = null;
              if (item.snapBack) {
                _positions[index] = _basePositions[index] ?? pos;
              }
            });
          },
          child: itemWidget,
        ),
      );
    }

    return Positioned(
      left: pos.dx - halfSize,
      top: pos.dy - halfSize,
      child: itemWidget,
    );
  }
}

/// A child item inside a [Liquid] container that melts with neighboring items.
///
/// Mirrors `<Liquid.Item effect="melt">` from `liquid-gooey`.
class LiquidItem extends StatefulWidget {
  const LiquidItem({
    super.key,
    required this.child,
    this.effect = LiquidEffect.melt,
    this.size = 84.0,
    this.borderRadius = 16.0,
    this.initialOffset,
    this.fluidColor,
    this.draggable = true,
    this.snapBack = false,
    this.onTap,
  });

  /// Inner content (e.g. image, avatar, icon, or badge) that stays sharp and crisp.
  final Widget child;

  /// The liquid effect applied to this item.
  final LiquidEffect effect;

  /// Bounding size of the item (diameter).
  final double size;

  /// Corner radius for the inner clip and outer gooey fluid halo.
  final double borderRadius;

  /// Optional fixed initial position within the [Liquid] container.
  final Offset? initialOffset;

  /// Optional specific fluid color for this item's gooey aura.
  final Color? fluidColor;

  /// Whether this item can be dragged by the user.
  final bool draggable;

  /// Whether the item returns to its initial position when released.
  final bool snapBack;

  final VoidCallback? onTap;

  @override
  State<LiquidItem> createState() => _LiquidItemState();
}

class _LiquidItemState extends State<LiquidItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final haloColor = widget.fluidColor ?? scheme.primary.withOpacity(0.35);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                // Viscous gooey halo background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.size + (_hovered ? 14 : 8),
                  height: widget.size + (_hovered ? 14 : 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius + 6),
                    color: haloColor,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: haloColor.withOpacity(0.55),
                        blurRadius: _hovered ? 24 : 14,
                        spreadRadius: _hovered ? 3 : 1,
                      ),
                    ],
                  ),
                ),

                // Crisp inner child content (matching exact liquid-gooey specification)
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class representing a gooey metaball circle node
class _MetaballCircle {
  _MetaballCircle({
    required this.center,
    required this.radius,
    required this.color,
  });

  final Offset center;
  final double radius;
  final Color color;
}

/// Custom painter that mathematically calculates smooth cubic bezier liquid
/// bridges between adjacent circles when they are within [meltDistance].
class _LiquidMetaballPainter extends CustomPainter {
  _LiquidMetaballPainter({
    required this.circles,
    required this.meltDistance,
    required this.defaultColor,
    required this.glowColor,
    required this.pulse,
    required this.effect,
  });

  final List<_MetaballCircle> circles;
  final double meltDistance;
  final Color defaultColor;
  final Color glowColor;
  final double pulse;
  final LiquidEffect effect;

  @override
  void paint(Canvas canvas, Size size) {
    if (circles.isEmpty) return;

    // Draw the fluid body and glow for each item node
    for (final c in circles) {
      final glow = Paint()
        ..color = glowColor.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);
      canvas.drawCircle(c.center, c.radius + 4, glow);

      final nodePaint = Paint()
        ..color = c.color.withOpacity(0.78)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(c.center, c.radius, nodePaint);
    }

    // Draw gooey liquid bridges between adjacent circles
    final n = circles.length;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        _drawMetaballBridge(canvas, circles[i], circles[j]);
      }
    }
  }

  void _drawMetaballBridge(Canvas canvas, _MetaballCircle c1, _MetaballCircle c2) {
    final dx = c2.center.dx - c1.center.dx;
    final dy = c2.center.dy - c1.center.dy;
    final d = math.sqrt(dx * dx + dy * dy);

    final r1 = c1.radius;
    final r2 = c2.radius;
    final maxDist = (r1 + r2) + meltDistance;

    // Too far apart to melt
    if (d >= maxDist || d <= (r1 - r2).abs()) return;

    // Proximity factor (1.0 = touching, 0.0 = edge of melt distance)
    final u = (1.0 - (d / maxDist)).clamp(0.0, 1.0);

    // Angle of connection
    final angle = math.atan2(dy, dx);

    // Calculate dynamic spread angle based on distance & viscosity
    final spread = math.pi / 2.2 * math.pow(u, 0.7);

    // Anchor points on Circle 1
    final p1a = Offset(
      c1.center.dx + r1 * math.cos(angle + spread),
      c1.center.dy + r1 * math.sin(angle + spread),
    );
    final p1b = Offset(
      c1.center.dx + r1 * math.cos(angle - spread),
      c1.center.dy + r1 * math.sin(angle - spread),
    );

    // Anchor points on Circle 2
    final p2a = Offset(
      c2.center.dx + r2 * math.cos(angle + math.pi - spread),
      c2.center.dy + r2 * math.sin(angle + math.pi - spread),
    );
    final p2b = Offset(
      c2.center.dx + r2 * math.cos(angle + math.pi + spread),
      c2.center.dy + r2 * math.sin(angle + math.pi + spread),
    );

    // Midpoint between circles
    final mid = Offset(
      (c1.center.dx + c2.center.dx) / 2,
      (c1.center.dy + c2.center.dy) / 2,
    );

    // Pinch factor for liquid gooey waist
    final waistPinch = (0.55 - u * 0.28).clamp(0.18, 0.58);
    final cpa = Offset.lerp(
      Offset((p1a.dx + p2a.dx) / 2, (p1a.dy + p2a.dy) / 2),
      mid,
      waistPinch,
    )!;
    final cpb = Offset.lerp(
      Offset((p1b.dx + p2b.dx) / 2, (p1b.dy + p2b.dy) / 2),
      mid,
      waistPinch,
    )!;

    final path = Path()
      ..moveTo(p1a.dx, p1a.dy)
      ..quadraticBezierTo(cpa.dx, cpa.dy, p2a.dx, p2a.dy)
      ..lineTo(p2b.dx, p2b.dy)
      ..quadraticBezierTo(cpb.dx, cpb.dy, p1b.dx, p1b.dy)
      ..close();

    // Fluid gradient along the bridge
    final bridgeGradient = LinearGradient(
      begin: Alignment(math.cos(angle), math.sin(angle)),
      end: Alignment(-math.cos(angle), -math.sin(angle)),
      colors: <Color>[
        c1.color.withOpacity((0.45 + u * 0.40).clamp(0.0, 0.95)),
        c2.color.withOpacity((0.45 + u * 0.40).clamp(0.0, 0.95)),
      ],
    );

    final paint = Paint()
      ..shader = bridgeGradient.createShader(
        Rect.fromPoints(c1.center, c2.center),
      )
      ..style = PaintingStyle.fill;

    // Subtle liquid glow blur behind the bridge
    final glowPaint = Paint()
      ..color = glowColor.withOpacity((0.35 * u).clamp(0.0, 0.6))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 * u);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidMetaballPainter oldDelegate) => true;
}

/// A liquid gooey tab bar where the selection indicator melts and morphs
/// across items like molten liquid.
class LiquidGooeyBar<T> extends StatefulWidget {
  const LiquidGooeyBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
    this.iconBuilder,
  });

  final List<T> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelBuilder;
  final IconData? Function(T)? iconBuilder;

  @override
  State<LiquidGooeyBar<T>> createState() => _LiquidGooeyBarState<T>();
}

class _LiquidGooeyBarState<T> extends State<LiquidGooeyBar<T>> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: widget.items.map((item) {
          final isSelected = item == widget.selected;
          final icon = widget.iconBuilder?.call(item);

          return LiquidGooeyButton(
            label: widget.labelBuilder(item),
            icon: icon,
            active: isSelected,
            compact: true,
            onPressed: () => widget.onSelected(item),
          );
        }).toList(),
      ),
    );
  }
}

/// An interactive button with molten liquid droplets that melt into the
/// button body on hover or click.
class LiquidGooeyButton extends StatefulWidget {
  const LiquidGooeyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.active = false,
    this.compact = false,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool active;
  final bool compact;
  final bool primary;

  @override
  State<LiquidGooeyButton> createState() => _LiquidGooeyButtonState();
}

class _LiquidGooeyButtonState extends State<LiquidGooeyButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _liquidController;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPrimary = widget.primary || widget.active;

    final bgGradient = isPrimary
        ? LinearGradient(
            colors: <Color>[
              scheme.primary,
              scheme.secondary,
            ],
          )
        : LinearGradient(
            colors: <Color>[
              scheme.surfaceContainerHighest.withOpacity(0.70),
              scheme.surface.withOpacity(0.85),
            ],
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovered ? 1.035 : 1.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 14 : 20,
              vertical: widget.compact ? 8 : 13,
            ),
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isPrimary
                    ? scheme.primary.withOpacity(0.6)
                    : scheme.outlineVariant.withOpacity(0.3),
              ),
              boxShadow: <BoxShadow>[
                if (isPrimary || _hovered)
                  BoxShadow(
                    color: scheme.primary.withOpacity(_hovered ? 0.40 : 0.22),
                    blurRadius: _hovered ? 20 : 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                // Liquid molten bubble accent that peaks on hover
                if (_hovered || isPrimary)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: AnimatedBuilder(
                      animation: _liquidController,
                      builder: (context, _) {
                        final wave = math.sin(_liquidController.value * math.pi * 2);
                        return Container(
                          width: 8 + wave * 2,
                          height: 8 + wave * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.secondary.withOpacity(0.8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: scheme.secondary,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.icon != null) ...<Widget>[
                      Icon(
                        widget.icon,
                        size: widget.compact ? 15 : 18,
                        color: isPrimary ? scheme.onPrimary : scheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: isPrimary ? scheme.onPrimary : scheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: widget.compact ? 12 : 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An interactive Liquid Gooey Photo Showcase component matching the user's
/// exact specification:
///
/// ```jsx
/// <Liquid>
///   <Liquid.Item effect="melt">
///     <img src="/photo-a.jpg" style={{ width: 84, height: 84, borderRadius: 16 }} />
///   </Liquid.Item>
///   <Liquid.Item effect="melt">
///     <img src="/photo-b.jpg" style={{ width: 84, height: 84, borderRadius: 16 }} />
///   </Liquid.Item>
/// </Liquid>
/// ```
class LiquidGooeyShowcase extends StatelessWidget {
  const LiquidGooeyShowcase({
    super.key,
    this.title = 'Interactive Liquid Gooey Melt',
    this.subtitle = 'Drag photos close together to watch them melt and merge into fluid liquid',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Specimen photos for the interactive liquid melt items
    final photos = <Map<String, dynamic>>[
      {
        'title': 'System A',
        'color': scheme.primary,
        'icon': Icons.auto_awesome_rounded,
        'gradient': <Color>[const Color(0xFFF64670), const Color(0xFFFF7E6B)],
      },
      {
        'title': 'System B',
        'color': scheme.secondary,
        'icon': Icons.layers_rounded,
        'gradient': <Color>[const Color(0xFF6B46C1), const Color(0xFF9F7AEA)],
      },
      {
        'title': 'System C',
        'color': const Color(0xFF00B4D8),
        'icon': Icons.analytics_rounded,
        'gradient': <Color>[const Color(0xFF0077B6), const Color(0xFF48CAE4)],
      },
      {
        'title': 'System D',
        'color': const Color(0xFF10B981),
        'icon': Icons.cloud_done_rounded,
        'gradient': <Color>[const Color(0xFF059669), const Color(0xFF34D399)],
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: scheme.primary.withOpacity(0.20),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withOpacity(0.08),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[scheme.primary, scheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.water_drop_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'LIQUID GOOEY EFFECT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'effect="melt"',
                style: TextStyle(
                  color: scheme.primary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Liquid Gooey Container with draggable photo items (84x84, borderRadius: 16)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest.withOpacity(0.60),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: scheme.outlineVariant.withOpacity(0.18),
                ),
              ),
              child: Liquid(
                height: 180,
                meltDistance: 130.0,
                effect: LiquidEffect.melt,
                children: photos.map((item) {
                  final colors = item['gradient'] as List<Color>;
                  final icon = item['icon'] as IconData;
                  final name = item['title'] as String;

                  return LiquidItem(
                    effect: LiquidEffect.melt,
                    size: 84.0,
                    borderRadius: 16.0,
                    fluidColor: colors.first,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: colors.first.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(icon, color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-screen interactive liquid gooey cursor overlay that trails the mouse,
/// stretches with fluid surface tension, and melts into interactive elements
/// like buttons, cards, and links when hovering.
class LiquidGooeyCursorOverlay extends StatefulWidget {
  const LiquidGooeyCursorOverlay({
    super.key,
    required this.child,
    this.trailLength = 7,
  });

  final Widget child;
  final int trailLength;

  @override
  State<LiquidGooeyCursorOverlay> createState() => _LiquidGooeyCursorOverlayState();
}

class _LiquidGooeyCursorOverlayState extends State<LiquidGooeyCursorOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  late final List<Offset> _trail;
  late final List<double> _baseRadii;

  Offset _target = const Offset(-200, -200);
  bool _visible = false;
  bool _isPressed = false;
  double _hoverIntensity = 0.0;

  @override
  void initState() {
    super.initState();
    _trail = List<Offset>.filled(widget.trailLength, const Offset(-200, -200), growable: true);
    _baseRadii = <double>[18.0, 15.0, 12.5, 10.5, 9.0, 7.5, 6.0];

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePhysics)..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    if (!mounted || !_visible) return;

    setState(() {
      // Lead node springs toward cursor target
      final lead = _trail[0];
      final dx = _target.dx - lead.dx;
      final dy = _target.dy - lead.dy;
      final speed = math.sqrt(dx * dx + dy * dy);

      // Interpolate lead node
      _trail[0] = Offset.lerp(lead, _target, 0.40)!;

      // Trailing nodes follow with viscous delay
      for (int i = 1; i < _trail.length; i++) {
        final lerpFactor = (0.35 - i * 0.028).clamp(0.12, 0.45);
        _trail[i] = Offset.lerp(_trail[i], _trail[i - 1], lerpFactor)!;
      }

      // Smooth hover scale
      final targetHover = speed < 2.5 ? 1.0 : 0.0;
      _hoverIntensity = _hoverIntensity + (targetHover - _hoverIntensity) * 0.12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      opaque: false,
      onEnter: (e) {
        setState(() {
          _visible = true;
          _target = e.position;
          for (int i = 0; i < _trail.length; i++) {
            _trail[i] = e.position;
          }
        });
      },
      onExit: (_) => setState(() => _visible = false),
      onHover: (e) => setState(() {
        _visible = true;
        _target = e.position;
      }),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. Underlying application
            widget.child,

            // 2. Full-screen Liquid Gooey Cursor Trail Layer
            if (_visible)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CursorLiquidPainter(
                      trail: _trail,
                      radii: _baseRadii,
                      isPressed: _isPressed,
                      hoverIntensity: _hoverIntensity,
                      primaryColor: scheme.primary,
                      secondaryColor: scheme.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the full-screen liquid gooey cursor and fluid tail
class _CursorLiquidPainter extends CustomPainter {
  _CursorLiquidPainter({
    required this.trail,
    required this.radii,
    required this.isPressed,
    required this.hoverIntensity,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<Offset> trail;
  final List<double> radii;
  final bool isPressed;
  final double hoverIntensity;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.isEmpty) return;

    final n = trail.length;
    final headRadius = isPressed
        ? (radii[0] * 1.6)
        : radii[0] + (hoverIntensity * 8.0);

    // 1. Draw gooey liquid bridges between consecutive trailing nodes
    for (int i = 0; i < n - 1; i++) {
      final p1 = trail[i];
      final p2 = trail[i + 1];
      final r1 = i == 0 ? headRadius : radii[i];
      final r2 = radii[i + 1];

      _drawCursorBridge(canvas, p1, r1, p2, r2, i, n);
    }

    // 2. Draw each fluid node body
    for (int i = n - 1; i >= 0; i--) {
      final pos = trail[i];
      final r = i == 0 ? headRadius : radii[i];
      final factor = (1.0 - (i / n)).clamp(0.2, 1.0);

      final nodeColor = Color.lerp(primaryColor, secondaryColor, (i / n))!;

      // Outer glow
      final glowPaint = Paint()
        ..color = nodeColor.withOpacity(0.35 * factor)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 * factor);
      canvas.drawCircle(pos, r + 3, glowPaint);

      // Solid fluid core
      final corePaint = Paint()
        ..color = nodeColor.withOpacity((0.65 + factor * 0.28).clamp(0.0, 0.95))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, r, corePaint);

      // Gloss sheen on the head droplet
      if (i == 0) {
        final sheenPaint = Paint()
          ..color = Colors.white.withOpacity(0.65)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(pos.dx - r * 0.35, pos.dy - r * 0.35),
          r * 0.28,
          sheenPaint,
        );
      }
    }
  }

  void _drawCursorBridge(
    Canvas canvas,
    Offset c1,
    double r1,
    Offset c2,
    double r2,
    int index,
    int total,
  ) {
    final dx = c2.dx - c1.dx;
    final dy = c2.dy - c1.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    final maxDist = (r1 + r2) * 3.8;

    if (d >= maxDist || d <= (r1 - r2).abs()) return;

    final u = (1.0 - (d / maxDist)).clamp(0.0, 1.0);
    final angle = math.atan2(dy, dx);
    final spread = math.pi / 2.1 * math.pow(u, 0.6);

    final p1a = Offset(c1.dx + r1 * math.cos(angle + spread), c1.dy + r1 * math.sin(angle + spread));
    final p1b = Offset(c1.dx + r1 * math.cos(angle - spread), c1.dy + r1 * math.sin(angle - spread));
    final p2a = Offset(c2.dx + r2 * math.cos(angle + math.pi - spread), c2.dy + r2 * math.sin(angle + math.pi - spread));
    final p2b = Offset(c2.dx + r2 * math.cos(angle + math.pi + spread), c2.dy + r2 * math.sin(angle + math.pi + spread));

    final mid = Offset((c1.dx + c2.dx) / 2, (c1.dy + c2.dy) / 2);
    final waist = (0.50 - u * 0.22).clamp(0.18, 0.52);

    final cpa = Offset.lerp(Offset((p1a.dx + p2a.dx) / 2, (p1a.dy + p2a.dy) / 2), mid, waist)!;
    final cpb = Offset.lerp(Offset((p1b.dx + p2b.dx) / 2, (p1b.dy + p2b.dy) / 2), mid, waist)!;

    final path = Path()
      ..moveTo(p1a.dx, p1a.dy)
      ..quadraticBezierTo(cpa.dx, cpa.dy, p2a.dx, p2a.dy)
      ..lineTo(p2b.dx, p2b.dy)
      ..quadraticBezierTo(cpb.dx, cpb.dy, p1b.dx, p1b.dy)
      ..close();

    final bridgeColor = Color.lerp(primaryColor, secondaryColor, index / total)!;
    final paint = Paint()
      ..color = bridgeColor.withOpacity((0.55 + u * 0.35).clamp(0.0, 0.92))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CursorLiquidPainter oldDelegate) => true;
}

/// A liquid gooey page route transition that sweeps an organic, viscous
/// molten fluid wave across the viewport when navigating between pages.
class LiquidGooeyPageTransition extends StatelessWidget {
  const LiquidGooeyPageTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final curve = CurvedAnimation(
      parent: animation,
      curve: const Cubic(0.22, 1, 0.36, 1),
      reverseCurve: const Cubic(0.4, 0, 0.2, 1),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, _) {
        final progress = curve.value;
        if (progress <= 0.005) return const SizedBox.shrink();

        final fade = (progress * 1.6).clamp(0.0, 1.0);
        final scale = 0.96 + 0.04 * progress;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. Incoming page with liquid wave boundary
            Opacity(
              opacity: fade,
              child: Transform.scale(
                scale: scale,
                child: ClipPath(
                  clipper: _LiquidWaveClipper(progress: progress),
                  child: child,
                ),
              ),
            ),

            // 2. Molten glowing crest along the advancing liquid front
            if (progress > 0.02 && progress < 0.98)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LiquidWaveCrestPainter(
                      progress: progress,
                      primaryColor: scheme.primary,
                      secondaryColor: scheme.secondary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Dynamic organic liquid wave clipper that forms viscous ripples and droplets
class _LiquidWaveClipper extends CustomClipper<Path> {
  const _LiquidWaveClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    if (progress >= 0.995) {
      return Path()..addRect(Offset.zero & size);
    }
    if (progress <= 0.005) {
      return Path();
    }

    final waveHeight = 52.0 * (1.0 - progress * 0.75);
    // Base wave line sweeping from bottom (size.height) to top (-waveHeight)
    final baseY = (1.0 - progress) * (size.height + waveHeight * 2.2) - waveHeight;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, (baseY + waveHeight).clamp(0.0, size.height));

    const steps = 48;
    final dx = size.width / steps;

    for (int i = 0; i <= steps; i++) {
      final x = i * dx;
      final nx = x / size.width;

      final wave1 = math.sin(nx * 3.4 * math.pi + progress * 5.2) * waveHeight;
      final wave2 = math.cos(nx * 5.8 * math.pi - progress * 3.8) * (waveHeight * 0.40);
      final wave3 = math.sin(nx * 8.2 * math.pi + progress * 7.0) * (waveHeight * 0.18);

      final y = (baseY + wave1 + wave2 + wave3).clamp(0.0, size.height);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _LiquidWaveClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Painter that renders a glowing molten liquid crest along the wave edge
class _LiquidWaveCrestPainter extends CustomPainter {
  _LiquidWaveCrestPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = 52.0 * (1.0 - progress * 0.75);
    final baseY = (1.0 - progress) * (size.height + waveHeight * 2.2) - waveHeight;

    final crestPath = Path();
    const steps = 48;
    final dx = size.width / steps;

    for (int i = 0; i <= steps; i++) {
      final x = i * dx;
      final nx = x / size.width;

      final wave1 = math.sin(nx * 3.4 * math.pi + progress * 5.2) * waveHeight;
      final wave2 = math.cos(nx * 5.8 * math.pi - progress * 3.8) * (waveHeight * 0.40);
      final wave3 = math.sin(nx * 8.2 * math.pi + progress * 7.0) * (waveHeight * 0.18);
      final y = (baseY + wave1 + wave2 + wave3).clamp(0.0, size.height);

      if (i == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }

    // Outer molten neon glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          primaryColor.withOpacity(0.85),
          secondaryColor.withOpacity(0.95),
          Colors.white.withOpacity(0.90),
        ],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 14.0 * (1.0 - progress * 0.4)
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawPath(crestPath, glowPaint);

    // Sharp white-hot fluid edge
    final sharpPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(crestPath, sharpPaint);

    // Floating detached liquid droplets ahead of the wave front
    final dropCount = 4;
    for (int d = 0; d < dropCount; d++) {
      final dropX = size.width * (0.2 + d * 0.22 + math.sin(progress * 4 + d) * 0.08);
      final dropY = (baseY - (22 + d * 14 + math.cos(progress * 5 + d) * 12))
          .clamp(0.0, size.height);
      final dropR = (6.5 - d * 0.9) * (1.0 - progress * 0.5);

      if (dropY > 0 && dropY < size.height) {
        final dropGlow = Paint()
          ..color = primaryColor.withOpacity(0.60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.drawCircle(Offset(dropX, dropY), dropR + 2, dropGlow);

        final dropPaint = Paint()
          ..color = Colors.white.withOpacity(0.90)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(dropX, dropY), dropR, dropPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidWaveCrestPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// A floating transparent liquid gooey navigation dock with fluid tab switching physics
class LiquidGooeyDock extends StatelessWidget {
  const LiquidGooeyDock({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTapIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = <Map<String, dynamic>>[
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Projects', 'icon': Icons.grid_view_rounded},
      {'label': 'Themes', 'icon': Icons.palette_outlined},
      {'label': 'Admin', 'icon': Icons.admin_panel_settings_outlined},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF1E1B24) : Colors.white).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: (isDark ? Colors.white24 : scheme.primary.withValues(alpha: 0.22)),
            width: 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            final icon = item['icon'] as IconData;
            final label = item['label'] as String;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _LiquidDockItem(
                label: label,
                icon: icon,
                active: isSelected,
                onTap: () => onTapIndex(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LiquidDockItem extends StatefulWidget {
  const _LiquidDockItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_LiquidDockItem> createState() => _LiquidDockItemState();
}

class _LiquidDockItemState extends State<_LiquidDockItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = widget.active
        ? Colors.white
        : (isDark ? Colors.white : scheme.onSurface);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: widget.active
                  ? LinearGradient(
                      colors: <Color>[
                        scheme.primary,
                        scheme.secondary,
                      ],
                    )
                  : (_hovered
                      ? LinearGradient(
                          colors: <Color>[
                            (isDark ? Colors.white : scheme.primary).withValues(alpha: 0.15),
                            (isDark ? Colors.white : scheme.secondary).withValues(alpha: 0.10),
                          ],
                        )
                      : null),
              color: widget.active
                  ? null
                  : (_hovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.active
                    ? scheme.primary.withValues(alpha: 0.55)
                    : (_hovered
                        ? (isDark ? Colors.white : scheme.primary).withValues(alpha: 0.35)
                        : Colors.transparent),
                width: 1.0,
              ),
              boxShadow: widget.active
                  ? <BoxShadow>[
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  widget.icon,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 7),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: widget.active ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                    height: 1.2,
                    shadows: widget.active
                        ? null
                        : <Shadow>[
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
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
