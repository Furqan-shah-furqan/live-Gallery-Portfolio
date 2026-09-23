import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/project_model.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.compact = false,
    this.deleteAction,
  });

  final ProjectModel project;
  final VoidCallback onTap;
  final bool compact;
  final VoidCallback? deleteAction;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final scheme = Theme.of(context).colorScheme;
    final height = widget.compact ? 300.0 : 390.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.012) : Offset.zero,
        duration: const Duration(milliseconds: 620),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedScale(
          scale: _hovered ? 1.008 : 1,
          duration: const Duration(milliseconds: 620),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 620),
            curve: const Cubic(0.22, 1, 0.36, 1),
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: scheme.surface.withOpacity(0.80),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.shadow.withOpacity(_hovered ? 0.84 : 0.58),
                  blurRadius: _hovered ? 56 : 38,
                  offset: const Offset(0, 22),
                ),
                if (_hovered)
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.12),
                    blurRadius: 56,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _projectGradient(project),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _ProjectMedia(project: project),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 560),
                          curve: const Cubic(0.22, 1, 0.36, 1),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Colors.transparent,
                                Colors.white.withOpacity(_hovered ? 0.24 : 0.14),
                                Colors.white.withOpacity(0.98),
                              ],
                              stops: const <double>[0, 0.52, 0.73, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 22,
                      child: AnimatedSlide(
                        offset: _hovered ? Offset.zero : const Offset(0, 0.04),
                        duration: const Duration(milliseconds: 560),
                        curve: const Cubic(0.22, 1, 0.36, 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              project.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: widget.compact ? 22 : 28,
                                height: 1.02,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    project.techStack,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: scheme.onSurface,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF00F0FF)),
                              SizedBox(width: 4),
                              Text(
                                'LIVE SYSTEM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.deleteAction != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1 : 0,
                          duration: const Duration(milliseconds: 420),
                          child: IconButton.filled(
                            tooltip: 'Delete project',
                            onPressed: widget.deleteAction,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.92),
                              foregroundColor: AppColors.danger,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectMedia extends StatelessWidget {
  const _ProjectMedia({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (project.images.isNotEmpty) {
      final bytes = project.images.first.decodeBytes();
      if (bytes != null) {
        return Hero(
          tag: 'project-${project.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: ColoredBox(
              color: scheme.surface,
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      }
    }

    return Hero(
      tag: 'project-${project.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _projectGradient(project),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -45,
                right: -35,
                child: _GlowOrb(
                  size: 190,
                  color: scheme.secondary.withOpacity(0.42),
                ),
              ),
              Positioned(
                left: -35,
                bottom: -55,
                child: _GlowOrb(
                  size: 220,
                  color: scheme.primary.withOpacity(0.34),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmWhite.withOpacity(0.80),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.softShadow.withOpacity(0.50),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Icon(
                        _iconForProject(project),
                        color: AppColors.ink,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      project.techStack,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[color, Colors.transparent],
        ),
      ),
    );
  }
}

IconData _iconForProject(ProjectModel project) {
  final value = '${project.name} ${project.techStack}'.toLowerCase();
  if (value.contains('flutter')) return Icons.flutter_dash_rounded;
  if (value.contains('pdf')) return Icons.picture_as_pdf_rounded;
  if (value.contains('calculator')) return Icons.calculate_rounded;
  if (value.contains('directory')) return Icons.grid_view_rounded;
  if (value.contains('download')) return Icons.download_for_offline_rounded;
  if (value.contains('clip')) return Icons.movie_filter_rounded;
  if (value.contains('management') || value.contains('business')) {
    return Icons.dashboard_customize_rounded;
  }
  return Icons.auto_awesome_rounded;
}

List<Color> _projectGradient(ProjectModel project) {
  final index = project.name.codeUnits.fold<int>(0, (sum, value) => sum + value) % 4;
  switch (index) {
    case 0:
      return <Color>[
        const Color(0xFFFFF4EC),
        const Color(0xFFFFC49D),
        const Color(0xFFFF6C82),
      ];
    case 1:
      return <Color>[
        const Color(0xFFFFE7DF),
        const Color(0xFFFFA36F),
        const Color(0xFFF64A76),
      ];
    case 2:
      return <Color>[
        const Color(0xFFFFF0F3),
        const Color(0xFFFF9BAE),
        const Color(0xFFFF6F67),
      ];
    default:
      return <Color>[
        const Color(0xFFFFF3E7),
        const Color(0xFFFFB66F),
        const Color(0xFFE93B6F),
      ];
  }
}
