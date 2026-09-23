import 'package:flutter/material.dart';

/// A viewport-aware animation widget that automatically triggers a smooth
/// fade, slide-up, and scale-in reveal animation as soon as the user scrolls
/// it into the viewport.
class ScrollAwareReveal extends StatefulWidget {
  const ScrollAwareReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 680),
    this.curve = const Cubic(0.22, 1, 0.36, 1),
    this.offset = const Offset(0, 36.0),
    this.scale = 0.94,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset offset;
  final double scale;

  @override
  State<ScrollAwareReveal> createState() => _ScrollAwareRevealState();
}

class _ScrollAwareRevealState extends State<ScrollAwareReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  bool _hasRevealed = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _scale = Tween<double>(begin: widget.scale, end: 1.0).animate(curved);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curved);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null && _scrollPosition != scrollable.position) {
      _scrollPosition?.removeListener(_checkVisibility);
      _scrollPosition = scrollable.position;
      _scrollPosition?.addListener(_checkVisibility);
    }
  }

  void _checkVisibility() {
    if (!mounted || _hasRevealed) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final position = renderObject.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Trigger reveal when the top of the widget is within 88% of viewport height
    if (position.dy < screenHeight * 0.88) {
      _hasRevealed = true;
      _scrollPosition?.removeListener(_checkVisibility);
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future<void>.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A scroll-driven animation widget that smoothly reveals
/// components with a staggered fade, scale, and vertical translation as they appear.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.curve = const Cubic(0.22, 1, 0.36, 1),
    this.offset = const Offset(0, 0.08),
    this.scale = 0.95,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset offset;
  final double scale;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _scale = Tween<double>(begin: widget.scale, end: 1.0).animate(curved);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: FractionalTranslation(
              translation: _slide.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A smooth parallax wrapper that shifts its child slightly as the user scrolls.
class ScrollParallaxItem extends StatelessWidget {
  const ScrollParallaxItem({
    super.key,
    required this.child,
    required this.controller,
    this.factor = 0.08,
    this.direction = Axis.vertical,
  });

  final Widget child;
  final ScrollController controller;
  final double factor;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final offset = controller.hasClients
            ? (controller.offset * factor).clamp(-40.0, 40.0)
            : 0.0;
        return Transform.translate(
          offset: direction == Axis.vertical
              ? Offset(0, offset)
              : Offset(offset, 0),
          child: child,
        );
      },
    );
  }
}

