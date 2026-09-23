import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
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
                                latestProject: store.latestProject,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 90),
      child: HeroCutoutLayout(
        projectCount: projectCount,
        latestProject: latestProject,
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
        radius: 45,
        opacity: 0.80,
        padding: const EdgeInsets.all(28),
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
                    const SizedBox(height: 12),
                    Text(
                      'Hover to expand every project story.',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: constraints.maxWidth < 600 ? 38 : 52,
                              ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: const Text(
                        'The first project opens in landscape by default. Move across the gallery to expand any other live system.',
                        style: TextStyle(
                          color: AppColors.inkMuted,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                );

                final actions = Wrap(
                  spacing: 12,
                  runSpacing: 10,
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
                      primary: false,
                      onPressed: widget.onAdmin,
                    ),
                  ],
                );

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      heading,
                      const SizedBox(height: 18),
                      actions,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: heading),
                    const SizedBox(width: 20),
                    actions,
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
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
            borderRadius: BorderRadius.circular(35),
            color: Colors.white.withOpacity(0.74),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.softShadow.withOpacity(active ? 0.78 : 0.52),
                blurRadius: active ? 44 : 28,
                offset: const Offset(0, 20),
              ),
              if (active)
                BoxShadow(
                  color: AppColors.cyan.withOpacity(0.10),
                  blurRadius: 52,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
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
                    left: 26,
                    right: 26,
                    bottom: 24,
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
                              color: AppColors.ink,
                              fontSize: 30,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.project.techStack,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.inkMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Icon(
                                Icons.arrow_outward_rounded,
                                color: AppColors.ink,
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
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.90),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.softShadow.withOpacity(0.65),
                                blurRadius: 20,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${widget.index + 1}'.padLeft(2, '0'),
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                color: AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
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
            color: const Color(0xFFFFF7F3),
            child: Padding(
              padding: EdgeInsets.all(active ? 12 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
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
              color: AppColors.orange.withOpacity(0.40),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -70,
            child: _DashboardOrb(
              size: 240,
              color: AppColors.hotPink.withOpacity(0.32),
            ),
          ),
          Center(
            child: AnimatedScale(
              scale: active ? 1 : 0.82,
              duration: const Duration(milliseconds: 620),
              curve: const Cubic(0.22, 1, 0.36, 1),
              child: Container(
                width: active ? 92 : 54,
                height: active ? 92 : 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.76),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.softShadow.withOpacity(0.48),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(
                  _accordionIcon(project),
                  color: AppColors.ink,
                  size: active ? 40 : 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

LinearGradient _accordionGradient(ProjectModel project) {
  final index =
      project.name.codeUnits.fold<int>(0, (sum, value) => sum + value) % 4;
  switch (index) {
    case 0:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFF4EC),
          Color(0xFFFFC79F),
          Color(0xFFFF6D83)
        ],
      );
    case 1:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFE9E1),
          Color(0xFFFFA66F),
          Color(0xFFF64A76)
        ],
      );
    case 2:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFF0F3),
          Color(0xFFFF9BAE),
          Color(0xFFFF6F67)
        ],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFF3E7),
          Color(0xFFFFB66F),
          Color(0xFFE93B6F)
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFFFEFE6),
            Color(0xFFFFD9DF),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.softShadow.withOpacity(0.50),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[
                  AppColors.orange,
                  AppColors.coral,
                  AppColors.hotPink
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.hotPink.withOpacity(0.24),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Projects added Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Open Admin Control to add project details, screenshots, technology, and a live link.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkMuted, height: 1.6),
          ),
          const SizedBox(height: 20),
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
        radius: 45,
        opacity: 0.075,
        padding: const EdgeInsets.all(30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionEyebrow('Contact'),
                const SizedBox(height: 12),
                Text(
                  'Have a useful product idea? Let’s build it.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: constraints.maxWidth < 600 ? 38 : 52,
                      ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Share the problem, users, and desired result. I can help turn it into a clean, responsive product.',
                  style: TextStyle(
                    color: AppColors.inkMuted,
                    height: 1.65,
                    fontSize: 16,
                  ),
                ),
              ],
            );

            final actions = Wrap(
              spacing: 12,
              runSpacing: 12,
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
                  const SizedBox(height: 24),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(child: copy),
                const SizedBox(width: 30),
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
                color: AppColors.inkMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Built in Flutter',
            style: TextStyle(
              color: AppColors.inkMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
