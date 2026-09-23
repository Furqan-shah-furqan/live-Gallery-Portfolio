import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 45,
    this.opacity = 0.76,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double opacity;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedOpacity = opacity < 0.3 ? 0.72 + opacity : opacity;
    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.58),
                  blurRadius: 52,
                  offset: const Offset(0, 24),
                ),
                BoxShadow(
                  color: scheme.primary.withOpacity(0.10),
                  blurRadius: 72,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: scheme.secondary.withOpacity(0.08),
                  blurRadius: 56,
                  offset: const Offset(-12, -8),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: scheme.surface.withOpacity(
                resolvedOpacity.clamp(0.0, 0.97).toDouble(),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.white.withOpacity(
                    (resolvedOpacity + 0.13).clamp(0.0, 0.99).toDouble(),
                  ),
                  scheme.surface.withOpacity(
                    (resolvedOpacity * 0.83).clamp(0.0, 0.96).toDouble(),
                  ),
                  scheme.surfaceContainerHigh.withOpacity(
                    (resolvedOpacity * 0.52).clamp(0.0, 0.78).toDouble(),
                  ),
                ],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    if (onTap == null) return content;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
}

class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.compact = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool compact;
  final bool danger;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = widget.danger
        ? const Color(0xFFFFE6EA)
        : Colors.white.withOpacity(_hovered ? 0.98 : 0.88);
    final foreground = widget.danger
        ? AppColors.danger
        : widget.primary
            ? Colors.white
            : scheme.onSurface;
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        scheme.secondary,
        scheme.tertiary,
        scheme.primary,
      ],
    );

    return MouseRegion(
      cursor: widget.onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered && widget.onPressed != null
            ? const Offset(0, -0.06)
            : Offset.zero,
        duration: const Duration(milliseconds: 520),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedScale(
          scale: _hovered && widget.onPressed != null ? 1.018 : 1,
          duration: const Duration(milliseconds: 520),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 520),
            curve: const Cubic(0.22, 1, 0.36, 1),
            decoration: BoxDecoration(
              color: widget.primary ? null : background,
              gradient: widget.primary ? primaryGradient : null,
              borderRadius: BorderRadius.circular(15),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.primary
                      ? scheme.primary.withOpacity(_hovered ? 0.34 : 0.22)
                      : scheme.shadow.withOpacity(_hovered ? 0.72 : 0.46),
                  blurRadius: _hovered ? 38 : 23,
                  offset: Offset(0, _hovered ? 15 : 10),
                ),
                if (widget.primary)
                  BoxShadow(
                    color:
                        scheme.secondary.withOpacity(_hovered ? 0.20 : 0.11),
                    blurRadius: 32,
                    offset: const Offset(-10, -4),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: widget.onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.compact ? 18 : 24,
                    vertical: widget.compact ? 13 : 17,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                        ),
                      ),
                      if (widget.icon != null) ...<Widget>[
                        const SizedBox(width: 10),
                        AnimatedRotation(
                          turns: _hovered ? 0.025 : 0,
                          duration: const Duration(milliseconds: 520),
                          curve: const Cubic(0.22, 1, 0.36, 1),
                          child: Icon(widget.icon, color: foreground, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 760),
      curve: const Cubic(0.22, 1, 0.36, 1),
      child: AnimatedScale(
        scale: _visible ? 1 : 0.985,
        duration: const Duration(milliseconds: 760),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : widget.offset,
          duration: const Duration(milliseconds: 760),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: widget.child,
        ),
      ),
    );
  }
}
