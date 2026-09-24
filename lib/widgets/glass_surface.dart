import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';

/// Aura-Bento card: pure white surface, hyper-curved corners, ambient
/// low-opacity/high-blur elevation, and an optional aura mesh wash sealed
/// behind the content with overflow hidden (§8 QA checklist).
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AuraBento.space6),
    this.radius = AuraBento.radiusLg,
    this.opacity = 1.0,
    this.shadow = true,
    this.mesh,
    this.meshOpacity = 0.65,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Corner radius. Child radii must respect R_inner = R_outer − padding.
  final double radius;

  /// Kept for call-site compatibility; aura cards stay ≥ 85% opaque.
  final double opacity;

  final bool shadow;

  /// Optional aura wash drawn behind content (§9.1 ::before equivalent).
  /// Colors are mesh gradient stops; null renders the plain white card.
  final List<Color>? mesh;

  final double meshOpacity;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveMesh = mesh ?? const <Color>[
      Color(0x73FFC896),
      Color(0x80B4BEFF),
    ];

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: AuraBento.surfaceWhite.withAlpha((opacity.clamp(0.85, 1.0) * 255).round()),
        boxShadow: shadow
            ? AuraBento.ambientMd(const Color(0xFF111827))
            : const <BoxShadow>[],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: <Widget>[
            if (mesh != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: meshOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.85, -0.9),
                          radius: 1.3,
                          colors: <Color>[
                            effectiveMesh.first,
                            effectiveMesh.first.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (mesh != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: meshOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.85, 0.9),
                          radius: 1.4,
                          colors: <Color>[
                            effectiveMesh.last,
                            effectiveMesh.last.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
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

/// §4.4 Pill Action Button — height 48, full pill radius, flat black-anchor
/// variant (no gradient, no box shadow), 14px bold white label, leading icon.
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.compact = false,
    this.danger = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool compact;
  final bool danger;
  final bool expand;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // §4.4 variants: Black Anchor / Aurora Gradient Pill / neutral capsule.
    final Color background;
    final Color foreground;
    final Gradient? gradient;

    if (widget.danger) {
      background = const Color(0xFFFDE8EC);
      foreground = AppColors.danger;
      gradient = null;
    } else if (widget.primary) {
      // §4.4 Black Anchor pill: flat solid black — no gradient, no glow.
      background =
          _hovered ? const Color(0xFF000000) : AuraBento.accentDarkAction;
      foreground = AuraBento.textInverted;
      gradient = null;
    } else {
      background = _hovered ? AuraBento.surfaceCardMuted : AuraBento.surfaceWhite;
      foreground = scheme.onSurface;
      gradient = null;
    }

    // Flat button treatment: the black action pills carry no box shadow.
    final shadows = widget.primary
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF111827).withAlpha(_hovered ? 22 : 12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ];

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AuraBento.radiusFull),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: widget.compact ? AuraBento.inputHeightCompact : AuraBento.ctaHeight,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? AuraBento.space4 : AuraBento.space5,
          ),
          decoration: BoxDecoration(
            color: background,
            gradient: gradient,
            borderRadius: BorderRadius.circular(AuraBento.radiusFull),
            border: widget.primary || widget.danger
                ? null
                : Border.all(color: AuraBento.surfacePillNeutralSolid),
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, color: foreground, size: 17),
                const SizedBox(width: AuraBento.space2),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Focus(
      canRequestFocus: widget.onPressed != null,
      onFocusChange: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      child: MouseRegion(
        cursor: widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: _AuraFocusRing(
          focused: _focused,
          radius: AuraBento.radiusFull,
          child: child,
        ),
      ),
    );
  }
}

/// §7 focus indicator: 2px #2A85FF outline, 2px offset (white on dark HUD).
class _AuraFocusRing extends StatelessWidget {
  const _AuraFocusRing({
    required this.child,
    this.focused = false,
    this.radius = AuraBento.radiusFull,
  });

  final Widget child;
  final bool focused;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final focusRing = AuraBento.accentBlueAction.withAlpha(210);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: focused ? focusRing : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: child,
    );
  }
}

/// §4.3 Pill Badge / Prompt Chip — height 32, 13px medium label, tinted wash
/// with dark text tokens (WCAG AA per §7).
class AuraBadge extends StatelessWidget {
  const AuraBadge({
    super.key,
    required this.text,
    this.icon,
    this.variant = AuraBadgeVariant.neutral,
    this.onDark = false,
  });

  final String text;
  final IconData? icon;
  final AuraBadgeVariant variant;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (variant) {
      case AuraBadgeVariant.amber:
        bg = AuraBento.badgeAmberBg;
        fg = AuraBento.badgeAmberText;
      case AuraBadgeVariant.lavender:
        bg = AuraBento.badgeLavenderBg;
        fg = AuraBento.badgeLavenderText;
      case AuraBadgeVariant.action:
        bg = AuraBento.accentDarkAction;
        fg = AuraBento.textInverted;
      case AuraBadgeVariant.neutral:
        bg = onDark ? const Color(0x1AFFFFFF) : AuraBento.badgeNeutralBg;
        fg = onDark ? const Color(0xE6FFFFFF) : AuraBento.badgeNeutralText;
    }

    return Container(
      height: AuraBento.badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: AuraBento.space4 - 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AuraBento.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

enum AuraBadgeVariant { neutral, amber, lavender, action }

/// §4.2 Circular Action Token — 44px (or 52px hero) perfect circle,
/// black / white / glass variants.
class AuraCircularToken extends StatelessWidget {
  const AuraCircularToken({
    super.key,
    required this.icon,
    this.onTap,
    this.size = AuraBento.touchTarget,
    this.variant = AuraCircularTokenVariant.pitchBlack,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final AuraCircularTokenVariant variant;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (variant) {
      case AuraCircularTokenVariant.pitchBlack:
        bg = AuraBento.accentDarkAction;
        fg = AuraBento.textInverted;
      case AuraCircularTokenVariant.pureWhite:
        bg = AuraBento.surfaceWhite;
        fg = AuraBento.textPrimary;
      case AuraCircularTokenVariant.glassNeutral:
        bg = const Color(0xA6FFFFFF); // rgba(255,255,255,.65)
        fg = AuraBento.textPrimary;
    }

    final Widget button = MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            // Flat black action tokens: no drop shadow (flat button spec).
            boxShadow: variant == AuraCircularTokenVariant.pureWhite
                ? AuraBento.ambientMd(const Color(0xFF111827))
                : variant == AuraCircularTokenVariant.glassNeutral
                    ? AuraBento.capsuleLift
                    : const <BoxShadow>[],
          ),
          child: Icon(icon, color: fg, size: size * 0.42),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

enum AuraCircularTokenVariant { pitchBlack, pureWhite, glassNeutral }

/// §4.5 Dynamic HUD step tracker (dark matte surface, #2A85FF nodes).
class AuraHudTracker extends StatelessWidget {
  const AuraHudTracker({
    super.key,
    required this.steps,
    this.activeIndex = 0,
  });

  final List<String> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraBento.space6,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AuraBento.surfaceDarkHud,
        borderRadius: BorderRadius.circular(AuraBento.radiusLg),
      ),
      child: Row(
        children: List<Widget>.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final completed = (i ~/ 2) < activeIndex;
            return Expanded(
              child: Container(
                height: AuraBento.hudConnectorHeight,
                margin: const EdgeInsets.symmetric(horizontal: AuraBento.space2),
                decoration: BoxDecoration(
                  color: completed
                      ? AuraBento.accentBlueAction
                      : const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final step = i ~/ 2;
          final completed = step < activeIndex;
          final active = step == activeIndex;
          final node = Container(
            width: AuraBento.hudNodeSize,
            height: AuraBento.hudNodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed || active ? AuraBento.accentBlueAction : null,
              border: completed || active
                  ? null
                  : Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 2,
                    ),
            ),
            child: completed
                ? const Icon(Icons.check_rounded,
                    color: AuraBento.textInverted, size: 14)
                : active
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AuraBento.textInverted,
                          ),
                        ),
                      )
                    : null,
          );
          return Tooltip(
            message: steps[step],
            child: node,
          );
        }),
      ),
    );
  }
}

/// Serif conversational headline helper (§2.2 font pairing).
class AuraSerif extends StatelessWidget {
  const AuraSerif(
    this.text, {
    super.key,
    this.fontSize = 40,
    this.height,
    this.color,
    this.textAlign,
  });

  final String text;
  final double fontSize;
  final double? height;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: AuraBento.fontSerif,
        fontSize: fontSize,
        height: height ?? 1.12,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
    );
  }
}

class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AuraBento.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
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
      duration: const Duration(milliseconds: 560),
      curve: const Cubic(0.22, 1, 0.36, 1),
      child: AnimatedScale(
        scale: _visible ? 1 : 0.99,
        duration: const Duration(milliseconds: 560),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : widget.offset,
          duration: const Duration(milliseconds: 560),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: widget.child,
        ),
      ),
    );
  }
}
