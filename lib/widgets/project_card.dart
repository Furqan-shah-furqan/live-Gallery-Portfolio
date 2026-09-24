import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
import '../models/project_model.dart';
import 'glass_surface.dart';

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
              borderRadius: BorderRadius.circular(AuraBento.radiusLg),
              color: AuraBento.surfaceWhite,
              boxShadow: AuraBento.ambientMd(const Color(0xFF111827)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AuraBento.radiusLg),
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
                        padding: const EdgeInsets.all(AuraBento.space3),
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
                      left: AuraBento.space5 + AuraBento.opticalInset(AuraBento.radiusLg) - 4,
                      right: AuraBento.space5 + AuraBento.opticalInset(AuraBento.radiusLg) - 4,
                      bottom: AuraBento.space5,
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
                                color: AuraBento.textPrimary,
                                fontSize: widget.compact ? 21 : 26,
                                height: 1.06,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AuraBento.space2),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    project.techStack,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AuraBento.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AuraBento.space2),
                                const Icon(
                                  Icons.arrow_outward_rounded,
                                  color: AuraBento.textPrimary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: AuraBento.space4,
                      left: AuraBento.space4,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.92,
                        duration: const Duration(milliseconds: 300),
                        child: const AuraBadge(
                          text: 'LIVE SYSTEM',
                          icon: Icons.bolt_rounded,
                          variant: AuraBadgeVariant.amber,
                        ),
                      ),
                    ),
                    if (widget.deleteAction != null)
                      Positioned(
                        top: AuraBento.space4 - 4,
                        right: AuraBento.space4 - 4,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1 : 0,
                          duration: const Duration(milliseconds: 420),
                          child: IconButton.filled(
                            tooltip: 'Delete project',
                            onPressed: widget.deleteAction,
                            style: IconButton.styleFrom(
                              backgroundColor: AuraBento.surfaceWhite,
                              foregroundColor: AppColors.danger,
                              shape: const CircleBorder(),
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
    if (project.images.isNotEmpty) {
      final bytes = project.images.first.decodeBytes();
      if (bytes != null) {
        return Hero(
          tag: 'project-${project.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AuraBento.innerRadius(AuraBento.radiusLg, AuraBento.space3),
            ),
            child: ColoredBox(
              color: AuraBento.canvasLightSecondary,
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
        borderRadius: BorderRadius.circular(
          AuraBento.innerRadius(AuraBento.radiusLg, AuraBento.space3),
        ),
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
                  color: Colors.white.withAlpha(150),
                ),
              ),
              Positioned(
                left: -35,
                bottom: -55,
                child: _GlowOrb(
                  size: 220,
                  color: Colors.white.withAlpha(110),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AuraBento.surfaceWhite,
                        boxShadow: AuraBento.ambientMd(const Color(0xFF111827)),
                      ),
                      child: Icon(
                        _iconForProject(project),
                        color: AuraBento.textPrimary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AuraBento.space4),
                    Text(
                      project.techStack,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AuraBento.textPrimary,
                        fontWeight: FontWeight.w500,
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

/// Aura mesh-card family fallbacks, keyed by project name.
List<Color> _projectGradient(ProjectModel project) {
  final index = project.name.codeUnits.fold<int>(0, (sum, value) => sum + value) % 4;
  switch (index) {
    case 0:
      return <Color>[
        const Color(0xFFFFF1E8),
        const Color(0xFFFFC9A8),
        const Color(0xFFB9C0FF),
      ];
    case 1:
      return <Color>[
        const Color(0xFFFFE9DC),
        const Color(0xFFFFB28F),
        const Color(0xFF9FAEFF),
      ];
    case 2:
      return <Color>[
        const Color(0xFFF2EEFF),
        const Color(0xFFD9CBFA),
        const Color(0xFFFFC9A8),
      ];
    default:
      return <Color>[
        const Color(0xFFEFF3FF),
        const Color(0xFFC3CDFB),
        const Color(0xFFFFB28F),
      ];
  }
}
