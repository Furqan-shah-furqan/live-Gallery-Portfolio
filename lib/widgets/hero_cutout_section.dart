import 'package:flutter/material.dart';

import '../models/project_model.dart';

/// Available orientations for inverted concave corner fillets.
enum InvertedCornerType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Custom painter that renders a true 45px concave "inverted fillet" wedge.
class InvertedCornerPainter extends CustomPainter {
  const InvertedCornerPainter({
    required this.color,
    required this.corner,
    this.radius = 45.0,
  });

  final Color color;
  final InvertedCornerType corner;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final r = radius;

    switch (corner) {
      case InvertedCornerType.topLeft:
        path.moveTo(0, 0);
        path.lineTo(r, 0);
        path.arcToPoint(
          Offset(0, r),
          radius: Radius.circular(r),
          clockwise: false,
        );
        path.close();
        break;

      case InvertedCornerType.topRight:
        path.moveTo(r, 0);
        path.lineTo(0, 0);
        path.arcToPoint(
          Offset(r, r),
          radius: Radius.circular(r),
          clockwise: true,
        );
        path.close();
        break;

      case InvertedCornerType.bottomLeft:
        path.moveTo(0, r);
        path.lineTo(r, r);
        path.arcToPoint(
          Offset(0, 0),
          radius: Radius.circular(r),
          clockwise: true,
        );
        path.close();
        break;

      case InvertedCornerType.bottomRight:
        path.moveTo(r, r);
        path.lineTo(0, r);
        path.arcToPoint(
          Offset(r, 0),
          radius: Radius.circular(r),
          clockwise: false,
        );
        path.close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant InvertedCornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.corner != corner ||
      oldDelegate.radius != radius;
}

/// Custom clipper that carves an inverted concave notch into the right edge
/// of the vertical navigation rail, matching Reference Image 1.
class LeftRailNotchClipper extends CustomClipper<Path> {
  const LeftRailNotchClipper({
    this.radius = 28.0,
    this.notchRadius = 26.0,
    this.notchCenterY = 240.0,
  });

  final double radius;
  final double notchRadius;
  final double notchCenterY;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;
    final nr = notchRadius;
    final cy = notchCenterY.clamp(r + nr + 20, h - r - nr - 20);

    // Top-left corner
    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    // Top edge to top-right corner
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));

    // Right edge down to notch entry
    path.lineTo(w, cy - nr - 14);
    // Smooth fillet into notch
    path.arcToPoint(
      Offset(w - 6, cy - nr),
      radius: const Radius.circular(12),
      clockwise: false,
    );
    // Concave notch arc
    path.arcToPoint(
      Offset(w - 6, cy + nr),
      radius: Radius.circular(nr),
      clockwise: false,
    );
    // Smooth fillet out of notch
    path.arcToPoint(
      Offset(w, cy + nr + 14),
      radius: const Radius.circular(12),
      clockwise: false,
    );

    // Continue down right edge to bottom-right corner
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    // Bottom edge to bottom-left corner
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    // Up left edge to close
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant LeftRailNotchClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchCenterY != notchCenterY;
}

/// The HeroCutoutLayout: An elite negative-space cutout layout for the
/// Hero Section representing the Futuristic Tablet OS Interface from Reference Image 1.
class HeroCutoutLayout extends StatefulWidget {
  const HeroCutoutLayout({
    super.key,
    required this.projectCount,
    required this.latestProject,
    required this.role,
    required this.onProjects,
    required this.onAdmin,
    required this.scrollController,
    this.onThemes,
  });

  final int projectCount;
  final ProjectModel? latestProject;
  final String role;
  final VoidCallback onProjects;
  final VoidCallback onAdmin;
  final ScrollController scrollController;
  final VoidCallback? onThemes;

  static const double radius = 45.0;
  static const Color darkCanvas = Color(0xFF090A10);
  static const Color tabletBezel = Color(0xFF1E212B);

  @override
  State<HeroCutoutLayout> createState() => _HeroCutoutLayoutState();
}

class _HeroCutoutLayoutState extends State<HeroCutoutLayout> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1040;
        final isTablet = constraints.maxWidth >= 720 && !isDesktop;

        return Column(
          children: <Widget>[
            // The Outer Tablet Device Chassis matching Reference Image 1
            Container(
              decoration: BoxDecoration(
                color: HeroCutoutLayout.darkCanvas,
                borderRadius: BorderRadius.circular(HeroCutoutLayout.radius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 2.2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                    blurRadius: 64,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.85),
                    blurRadius: 72,
                    offset: const Offset(0, 32),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isDesktop ? 18.0 : 12.0),
              child: isDesktop
                  ? _buildDesktopTablet(context)
                  : isTablet
                      ? _buildTabletMode(context)
                      : _buildMobileMode(context),
            ),
          ],
        );
      },
    );
  }

  /// 1. Desktop Tablet Layout
  Widget _buildDesktopTablet(BuildContext context) {
    return SizedBox(
      height: 580,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Column 1: Left Navigation Rail with Cutout Notch and Down-Arrow Button
          _buildLeftRail(context, height: 580),

          const SizedBox(width: 14),

          // Column 2: Main Center Hero Stage
          Expanded(
            child: _buildCenterHeroStage(context),
          ),
        ],
      ),
    );
  }

  /// 2. Tablet Layout
  Widget _buildTabletMode(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildLeftRail(context, height: 520),
          const SizedBox(width: 12),
          Expanded(child: _buildCenterHeroStage(context)),
        ],
      ),
    );
  }

  /// 3. Mobile Layout
  Widget _buildMobileMode(BuildContext context) {
    return SizedBox(
      height: 520,
      child: _buildCenterHeroStage(context),
    );
  }

  /// Column 1: Left Navigation Rail with Inverted Cutout Notch
  Widget _buildLeftRail(BuildContext context, {required double height}) {
    final notchY = height * 0.46;

    return SizedBox(
      width: 68,
      child: Column(
        children: <Widget>[
          // Top Circular Button with 4-point star icon - opens Gallery Viewer
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Gallery Viewer (All Projects)',
              onPressed: widget.onProjects,
              icon: const Icon(
                Icons.photo_library_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Vertical Polar-White Rail with Inverted Cutout Notch
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // Rail Body with Cutout Notch Clipper
                ClipPath(
                  clipper: LeftRailNotchClipper(
                    radius: 25.0,
                    notchRadius: 26.0,
                    notchCenterY: notchY - 68,
                  ),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _navItem(0, Icons.home_rounded, 'Home (Top)'),
                        _navItem(1, Icons.photo_library_rounded, 'Gallery Viewer'),
                        _navItem(2, Icons.grid_view_rounded, 'Live Systems'),
                        _navItem(3, Icons.admin_panel_settings_rounded, 'Admin Console'),
                        if (widget.onThemes != null)
                          _navItem(4, Icons.palette_outlined, 'Theme Studio'),
                        const Divider(color: Color(0xFFE2E8F0), height: 12),
                        _navItem(5, Icons.arrow_upward_rounded, 'Back to Top'),
                        // Avatar profile at bottom
                        Tooltip(
                          message: 'Admin Access',
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.onAdmin,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: <Color>[Color(0xFFFF9B67), Color(0xFFF83D76)],
                                  ),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: const Color(0xFFF83D76).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Inverted Cutout Notch Action Button (Arrow Down) - Smooth Scroll to Systems
                Positioned(
                  left: 36,
                  top: (notchY - 68) - 17,
                  child: Tooltip(
                    message: 'Scroll to Live Systems',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          widget.scrollController.animateTo(
                            580,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x28000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String tooltip) {
    final active = _selectedNavIndex == index;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedNavIndex = index);
            if (index == 0) {
              widget.scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
              );
            } else if (index == 1) {
              widget.onProjects();
            } else if (index == 2) {
              widget.scrollController.animateTo(
                580,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
              );
            } else if (index == 3) {
              widget.onAdmin();
            } else if (index == 4 && widget.onThemes != null) {
              widget.onThemes!();
            } else if (index == 5) {
              widget.scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: active ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                icon,
                color: active ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Column 2: Main Center Hero Stage (Cyberpunk Canvas)
  Widget _buildCenterHeroStage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: <Widget>[
            // Ambient glowing cyan & violet backdrop orbs
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      const Color(0xFF00F0FF).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      const Color(0xFFA855F7).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Parallax Robot Graphic
            Positioned.fill(
              child: AnimatedBuilder(
                animation: widget.scrollController,
                child: Image.asset(
                  'assets/images/hero_robot.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  filterQuality: FilterQuality.high,
                ),
                builder: (context, child) {
                  final offset = widget.scrollController.hasClients
                      ? (widget.scrollController.offset * 0.12).clamp(0.0, 32.0).toDouble()
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 40, 20, 40),
                      child: child,
                    ),
                  );
                },
              ),
            ),

            // Top Bar with Status Badge and Direct Quick Action Buttons
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                        SizedBox(width: 6),
                        Text(
                          'AI SYSTEM ONLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Buttons: Gallery Viewer, Admin Console, Search
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Direct Gallery Viewer Button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onProjects,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.photo_library_rounded, color: Colors.white, size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Gallery Viewer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Direct Admin Console Button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onAdmin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.40)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00F0FF), size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Color(0xFF00F0FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Search Pill
                      Container(
                        width: 170,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 14,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.search_rounded, color: Colors.black87, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) => widget.onProjects(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Left Hero Typography Overlay
            Positioned(
              left: 28,
              bottom: 28,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Eyebrow Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.35)),
                      ),
                      child: const Text(
                        'AUTONOMOUS FLUTTER INTERFACES',
                        style: TextStyle(
                          color: Color(0xFF00F0FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Display Title
                    const Text(
                      'Live Systems\nGallery.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 0.98,
                        letterSpacing: -2.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / Active Role
                    Text(
                      widget.role,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Call to Action Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: <Widget>[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: widget.onProjects,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: <Color>[Color(0xFF00F0FF), Color(0xFFA855F7)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Explore Gallery',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_outward_rounded, color: Colors.black, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: widget.onAdmin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.lock_open_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Admin Control',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

