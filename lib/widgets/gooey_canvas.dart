import 'dart:ui';
import 'package:flutter/material.dart';

/// A high-performance, organic Gooey / Metaball canvas engine.
///
/// It coordinates a background "gooey fluid layer" (which undergoes
/// [ImageFilter.blur] followed by an alpha-threshold [ColorFilter.matrix]
/// to melt touching or close components together) and overlays a crisp,
/// un-blurred foreground content layer exactly in sync.
class GooeyCanvas extends StatelessWidget {
  const GooeyCanvas({
    super.key,
    required this.backgroundShapes,
    required this.foregroundContent,
    this.blurSigma = 18.0,
    this.alphaMultiplier = 35.0,
    this.alphaOffset = -18.0,
    this.clipBehavior = Clip.none,
    this.fit = StackFit.loose,
  });

  /// The fluid background shapes (bubbles, cards, pills) that will blur and fuse
  /// into one another organically.
  final Widget backgroundShapes;

  /// The crisp, un-blurred text, icons, and media elements that sit in front.
  final Widget foregroundContent;

  /// Blur amount applied to the background shapes before thresholding.
  final double blurSigma;

  /// Alpha multiplier used to restore a sharp, liquid edge to blurred shapes.
  final double alphaMultiplier;

  /// Alpha offset (in normalized scale or 0-255 bias) to threshold the boundary.
  final double alphaOffset;

  /// Stack clip behavior.
  final Clip clipBehavior;

  /// Stack fit behavior.
  final StackFit fit;

  /// Threshold color matrix to create the signature SVG/Canvas gooey filter effect:
  ///
  /// ```
  /// [ 1, 0, 0, 0, 0,
  ///   0, 1, 0, 0, 0,
  ///   0, 0, 1, 0, 0,
  ///   0, 0, 0, alphaMultiplier, alphaOffset * 255 ]
  /// ```
  List<double> _createThresholdMatrix() {
    return <double>[
      1.0, 0.0, 0.0, 0.0, 0.0, // R
      0.0, 1.0, 0.0, 0.0, 0.0, // G
      0.0, 0.0, 1.0, 0.0, 0.0, // B
      0.0, 0.0, 0.0, alphaMultiplier, alphaOffset * 255.0, // A
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matrix = _createThresholdMatrix();

    return Stack(
      fit: fit,
      clipBehavior: clipBehavior,
      children: <Widget>[
        // Layer 1: Gooey Filtered Liquid Background Layer
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
              tileMode: TileMode.decal,
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(matrix),
              child: backgroundShapes,
            ),
          ),
        ),

        // Layer 2: Ultra-Crisp Foreground Content Layer
        foregroundContent,
      ],
    );
  }
}

/// A liquid fluid pill / bubble shape designed to be placed inside the
/// background layer of a [GooeyCanvas] or used standalone with gooey styling.
class GooeyFluidBubble extends StatelessWidget {
  const GooeyFluidBubble({
    super.key,
    required this.color,
    this.borderRadius = 45.0,
    this.child,
    this.gradient,
    this.width,
    this.height,
  });

  final Color color;
  final double borderRadius;
  final Widget? child;
  final Gradient? gradient;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// A liquid spring container that animates scale, slide, and corner changes
/// with an elastic, organic liquid bounce.
class LiquidSpringBounce extends StatefulWidget {
  const LiquidSpringBounce({
    super.key,
    required this.child,
    this.scale = 1.0,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.elasticOut,
  });

  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<LiquidSpringBounce> createState() => _LiquidSpringBounceState();
}

class _LiquidSpringBounceState extends State<LiquidSpringBounce> {
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.scale,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }
}
