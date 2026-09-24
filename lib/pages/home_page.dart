import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
import '../models/project_model.dart';
import '../services/project_store.dart';
import '../widgets/animated_mesh_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/project_card.dart';
import 'admin_access.dart';
import 'project_detail_page.dart';
import 'projects_page.dart';
import 'theme_page.dart';
import '../widgets/hero_cutout_section.dart';
import '../widgets/scroll_reveal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _roles = <String>[
    'Flutter & Supabase product developer',
    'Builder of practical web tools',
    'Business workflow system designer',
    'AI-assisted product developer',
  ];

  Timer? _roleTimer;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _roleNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _roleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _roleNotifier.value = (_roleNotifier.value + 1) % _roles.length;
    });
  }

  @override
  void dispose() {
    _roleTimer?.cancel();
    _roleNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ProjectStoreScope.of(context);

    return AnimatedMeshBackground(
      scrollController: _scrollController,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1480),
                    child: Column(
                      children: <Widget>[
                        RepaintBoundary(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _roleNotifier,
                            builder: (context, roleIndex, _) {
                              return _HeroSection(
                                projectCount: store.count,
                                role: _roles[roleIndex],
                                onProjects: () => _openProjects(context),
                                onAdmin: () => _openAdmin(context),
                                onThemes: () => _openThemes(context),
                                scrollController: _scrollController,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 36),
                        RepaintBoundary(
                          child: ScrollAwareReveal(
                            delay: const Duration(milliseconds: 60),
                            child: _ProjectPreviewSection(
                              projects: store.projects.take(6).toList(),
                              onExplore: () => _openProjects(context),
                              onAdmin: () => _openAdmin(context),
                              onOpenProject: (project) =>
                                  _openProject(context, project),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        RepaintBoundary(
                          child: ScrollAwareReveal(
                            delay: const Duration(milliseconds: 60),
                            child: _ContactSection(
                              onEmail: () => _launch(
                                Uri(
                                  scheme: 'mailto',
                                  path: 'furqanfff6@gmail.com',
                                  queryParameters: <String, String>{
                                    'subject': 'Portfolio project enquiry',
                                    'body':
                                        'Hello Furqan, I want to discuss a project.',
                                  },
                                ),
                              ),
                              onWhatsApp: () => _launch(
                                Uri.parse(
                                  'https://wa.me/?text=${Uri.encodeComponent('Hello Furqan, I want to discuss a project.')}',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const RepaintBoundary(child: _Footer()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openProjects(BuildContext context) {
    Navigator.of(context).push(
      PremiumPageRoute<void>(page: const ProjectsPage()),
    );
  }

  void _openThemes(BuildContext context) {
    Navigator.of(context).push(
      PremiumPageRoute<void>(page: const ThemePage()),
    );
  }

  Future<void> _openAdmin(BuildContext context) async {
    await openProtectedAdmin(context);
  }

  void _openProject(BuildContext context, ProjectModel project) {
    Navigator.of(context).push(
      PremiumPageRoute<void>(
        page: ProjectDetailPage(projectId: project.id),
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.projectCount,
    required this.role,
    required this.onProjects,
    required this.onAdmin,
    required this.scrollController,
    this.onThemes,
  });

  final int projectCount;
  final String role;
  final VoidCallback onProjects;
  final VoidCallback onAdmin;
  final ScrollController scrollController;
  final VoidCallback? onThemes;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 90),
      child: HeroCutoutLayout(
        projectCount: projectCount,
        role: role,
        onProjects: onProjects,
        onAdmin: onAdmin,
        onThemes: onThemes,
        scrollController: scrollController,
      ),
    );
  }
}

class _ProjectPreviewSection extends StatefulWidget {
  const _ProjectPreviewSection({
    required this.projects,
    required this.onExplore,
    required this.onAdmin,
    required this.onOpenProject,
  });

  final List<ProjectModel> projects;
  final VoidCallback onExplore;
  final VoidCallback onAdmin;
  final ValueChanged<ProjectModel> onOpenProject;

  @override
  State<_ProjectPreviewSection> createState() => _ProjectPreviewSectionState();
}

class _ProjectPreviewSectionState extends State<_ProjectPreviewSection> {
  int _activeIndex = 0;

  @override
  void didUpdateWidget(covariant _ProjectPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.projects.isEmpty) {
      _activeIndex = 0;
    } else if (_activeIndex >= widget.projects.length) {
      _activeIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 180),
      child: GlassSurface(
        radius: AuraBento.radiusXl,
        padding: const EdgeInsets.all(AuraBento.space8 - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 760;
                final heading = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SectionEyebrow('Selected live systems'),
                    const SizedBox(height: AuraBento.space3),
                    Text(
                      'Hover to expand every project story.',
                      style: TextStyle(
                        fontFamily: AuraBento.fontSerif,
                        color: AuraBento.textPrimary,
                        fontSize: constraints.maxWidth < 600 ? 34 : 46,
                        height: 1.08,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AuraBento.space2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Text(
                        'The first project opens in landscape by default. Move across the gallery to expand any other live system.',
                        style: TextStyle(
                          color: AuraBento.textSecondary,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );

                final actions = Wrap(
                  spacing: AuraBento.space3,
                  runSpacing: AuraBento.space2,
                  children: <Widget>[
                    PremiumButton(
                      label: 'Explore Gallery',
                      icon: Icons.photo_library_rounded,
                      primary: true,
                      onPressed: widget.onExplore,
                    ),
                    PremiumButton(
                      label: 'Admin Control',
                      icon: Icons.admin_panel_settings_rounded,
                      onPressed: widget.onAdmin,
                    ),
                  ],
                );

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      heading,
                      const SizedBox(height: AuraBento.space4),
                      actions,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: heading),
                    const SizedBox(width: AuraBento.space5),
                    actions,
                  ],
                );
              },
            ),
            const SizedBox(height: AuraBento.space6),
            if (widget.projects.isEmpty)
              _EmptyProjects(onAdmin: widget.onAdmin)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 820) {
                    return Column(
                      children: List<Widget>.generate(
                        widget.projects.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index == widget.projects.length - 1 ? 0 : 14,
                          ),
                          child: AnimatedEntrance(
                            delay: Duration(milliseconds: 70 * index),
                            child: ProjectCard(
                              project: widget.projects[index],
                              compact: true,
                              onTap: () =>
                                  widget.onOpenProject(widget.projects[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  const collapsedWidth = 100.0;
                  const gap = 12.0;
                  final totalGaps = gap * (widget.projects.length - 1);
                  final expandedWidth = math.max(
                    320.0,
                    constraints.maxWidth -
                        collapsedWidth * (widget.projects.length - 1) -
                        totalGaps,
                  );

                  return MouseRegion(
                    onExit: (_) {
                      if (_activeIndex != 0) setState(() => _activeIndex = 0);
                    },
                    child: SizedBox(
                      height: 430,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List<Widget>.generate(
                            widget.projects.length,
                            (index) {
                              final active = index == _activeIndex;
                              final project = widget.projects[index];

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == widget.projects.length - 1
                                      ? 0
                                      : gap,
                                ),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) {
                                    if (_activeIndex != index) {
                                      setState(() => _activeIndex = index);
                                    }
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_activeIndex == index) {
                                        widget.onOpenProject(project);
                                      } else {
                                        setState(() => _activeIndex = index);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      width: active
                                          ? expandedWidth
                                          : collapsedWidth,
                                      height: 430,
                                      duration:
                                          const Duration(milliseconds: 380),
                                      curve: const Cubic(0.22, 1, 0.36, 1),
                                      child: _AccordionProjectCard(
                                        project: project,
                                        index: index,
                                        active: active,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AccordionProjectCard extends StatefulWidget {
  const _AccordionProjectCard({
    required this.project,
    required this.index,
    required this.active,
  });

  final ProjectModel project;
  final int index;
  final bool active;

  @override
  State<_AccordionProjectCard> createState() => _AccordionProjectCardState();
}

class _AccordionProjectCardState extends State<_AccordionProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.012) : Offset.zero,
        duration: const Duration(milliseconds: 520),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 620),
          curve: const Cubic(0.22, 1, 0.36, 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuraBento.radiusLg),
            color: AuraBento.surfaceWhite,
            boxShadow: AuraBento.ambientMd(const Color(0xFF111827)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AuraBento.radiusLg),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _AccordionProjectMedia(
                  project: widget.project,
                  active: active,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 620),
                  curve: const Cubic(0.22, 1, 0.36, 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: active
                          ? <Color>[
                              Colors.transparent,
                              Colors.transparent,
                              Colors.white.withOpacity(0.20),
                              Colors.white.withOpacity(0.97),
                            ]
                          : <Color>[
                              Colors.white.withOpacity(0.02),
                              Colors.white.withOpacity(0.22),
                              Colors.white.withOpacity(0.48),
                            ],
                      stops: active
                          ? const <double>[0, 0.50, 0.72, 1]
                          : const <double>[0, 0.65, 1],
                    ),
                  ),
                ),
                if (active)
                  Positioned(
                    left: AuraBento.space6 - 2,
                    right: AuraBento.space6 - 2,
                    bottom: AuraBento.space6,
                    child: AnimatedOpacity(
                      opacity: active ? 1 : 0,
                      duration: const Duration(milliseconds: 520),
                      curve: const Cubic(0.22, 1, 0.36, 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AuraBento.textPrimary,
                              fontSize: 28,
                              height: 1.05,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: AuraBento.space2),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.project.techStack,
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
                  )
                else ...<Widget>[
                  Positioned(
                    bottom: AuraBento.space4,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AuraBento.surfaceWhite,
                            boxShadow:
                                AuraBento.ambientSm(const Color(0xFF111827)),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.index + 1}'.padLeft(2, '0'),
                              style: const TextStyle(
                                color: AuraBento.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AuraBento.space3),
                        RotatedBox(
                          quarterTurns: 3,
                          child: SizedBox(
                            width: 210,
                            child: Text(
                              widget.project.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AuraBento.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardOrb extends StatelessWidget {
  const _DashboardOrb({required this.size, required this.color});

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

class _AccordionProjectMedia extends StatelessWidget {
  const _AccordionProjectMedia({
    required this.project,
    required this.active,
  });

  final ProjectModel project;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (project.images.isNotEmpty) {
      final bytes = project.images.first.decodeBytes();
      if (bytes != null) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 560),
          switchInCurve: const Cubic(0.22, 1, 0.36, 1),
          child: ColoredBox(
            key: ValueKey<bool>(active),
            color: AuraBento.canvasLightSecondary,
            child: Padding(
              padding: EdgeInsets.all(active ? AuraBento.space3 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AuraBento.innerRadius(AuraBento.radiusLg, AuraBento.space3),
                ),
                child: Image.memory(
                  bytes,
                  fit: active ? BoxFit.contain : BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        );
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _accordionGradient(project),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -60,
            right: -50,
            child: _DashboardOrb(
              size: 220,
              color: const Color(0x66FFC896),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -70,
            child: _DashboardOrb(
              size: 240,
              color: const Color(0x73B4BEFF),
            ),
          ),
          Center(
            child: AnimatedScale(
              scale: active ? 1 : 0.82,
              duration: const Duration(milliseconds: 620),
              curve: const Cubic(0.22, 1, 0.36, 1),
              child: Container(
                width: active ? 88 : 52,
                height: active ? 88 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuraBento.surfaceWhite,
                  boxShadow: AuraBento.ambientMd(const Color(0xFF111827)),
                ),
                child: Icon(
                  _accordionIcon(project),
                  color: AuraBento.textPrimary,
                  size: active ? 36 : 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft aura-tinted fallback gradients (mesh-card family) keyed by project name.
LinearGradient _accordionGradient(ProjectModel project) {
  final index =
      project.name.codeUnits.fold<int>(0, (sum, value) => sum + value) % 4;
  switch (index) {
    case 0:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFF1E8),
          Color(0xFFFFC9A8),
          Color(0xFFB9C0FF),
        ],
      );
    case 1:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFE9DC),
          Color(0xFFFFB28F),
          Color(0xFF9FAEFF),
        ],
      );
    case 2:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF2EEFF),
          Color(0xFFD9CBFA),
          Color(0xFFFFC9A8),
        ],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFEFF3FF),
          Color(0xFFC3CDFB),
          Color(0xFFFFB28F),
        ],
      );
  }
}

IconData _accordionIcon(ProjectModel project) {
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

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.onAdmin});

  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AuraBento.space6,
        vertical: 54,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuraBento.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF6F7FA),
            Color(0xFFFDEFE4),
            Color(0xFFE9ECFB),
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AuraBento.surfaceWhite,
              boxShadow: AuraBento.ambientMd(const Color(0xFF111827)),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AuraBento.accentOrange,
              size: 28,
            ),
          ),
          const SizedBox(height: AuraBento.space4),
          const Text(
            'No Projects added Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AuraBento.fontSerif,
              color: AuraBento.textPrimary,
              fontSize: 28,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AuraBento.space2),
          const Text(
            'Open Admin Control to add project details, screenshots, technology, and a live link.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuraBento.textSecondary,
              height: 1.6,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AuraBento.space5),
          PremiumButton(
            label: 'Open Admin Control',
            icon: Icons.lock_open_rounded,
            primary: true,
            onPressed: onAdmin,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.onEmail, required this.onWhatsApp});

  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 340),
      child: GlassSurface(
        radius: AuraBento.radiusXl,
        padding: const EdgeInsets.all(AuraBento.space8 - 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionEyebrow('Contact'),
                const SizedBox(height: AuraBento.space3),
                Text(
                  'Have a useful product idea? Let’s build it.',
                  style: TextStyle(
                    fontFamily: AuraBento.fontSerif,
                    color: AuraBento.textPrimary,
                    fontSize: constraints.maxWidth < 600 ? 34 : 46,
                    height: 1.08,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AuraBento.space3),
                const Text(
                  'Share the problem, users, and desired result. I can help turn it into a clean, responsive product.',
                  style: TextStyle(
                    color: AuraBento.textSecondary,
                    height: 1.65,
                    fontSize: 14,
                  ),
                ),
              ],
            );

            final actions = Wrap(
              spacing: AuraBento.space3,
              runSpacing: AuraBento.space3,
              children: <Widget>[
                PremiumButton(
                  label: 'Send Email',
                  icon: Icons.mail_outline_rounded,
                  primary: true,
                  onPressed: onEmail,
                ),
                PremiumButton(
                  label: 'Open WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: onWhatsApp,
                ),
              ],
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  copy,
                  const SizedBox(height: AuraBento.space6),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(child: copy),
                const SizedBox(width: AuraBento.space8),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              '© 2026 Furqan · Live Systems Gallery',
              style: TextStyle(
                color: AuraBento.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AuraBento.accentBlueAction,
            ),
          ),
          const SizedBox(width: AuraBento.space2),
          const Text(
            'Built in Flutter',
            style: TextStyle(
              color: AuraBento.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
