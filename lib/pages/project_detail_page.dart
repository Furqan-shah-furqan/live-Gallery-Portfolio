import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../models/project_model.dart';
import '../services/project_store.dart';
import '../widgets/animated_mesh_background.dart';
import '../widgets/glass_surface.dart';
import 'theme_page.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final PageController _pageController = PageController();

  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ProjectStoreScope.of(context);

    return AnimatedMeshBackground(
      darkness: 0.92,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              ProjectModel? project;

              for (final item in store.projects) {
                if (item.id == widget.projectId) {
                  project = item;
                  break;
                }
              }

              if (project == null) {
                return Center(
                  child: GlassSurface(
                    radius: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Project not found',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        PremiumButton(
                          label: 'Go Back',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1480,
                    ),
                    child: Column(
                      children: <Widget>[
                        _DetailHeader(
                          title: project.name,
                          onBack: () => Navigator.of(context).pop(),
                          onThemes: () {
                            Navigator.of(context).push(
                              PremiumPageRoute<void>(
                                page: const ThemePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool wide =
                                constraints.maxWidth >= 980;

                            final gallery = _ProjectGallery(
                              project: project!,
                              pageController: _pageController,
                              pageIndex: _pageIndex,
                              onChanged: (value) {
                                setState(() {
                                  _pageIndex = value;
                                });
                              },
                              onPrevious: () => _move(project!, -1),
                              onNext: () => _move(project!, 1),
                            );

                            if (wide) {
                              const double gap = 20;

                              final double galleryWidth =
                                  (constraints.maxWidth - gap) * 7 / 11;

                              final double galleryHeight =
                                  ((galleryWidth * 9 / 16) + 12)
                                      .clamp(350.0, 465.0)
                                      .toDouble();

                              return Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: SizedBox(
                                      height: galleryHeight,
                                      child: gallery,
                                    ),
                                  ),
                                  const SizedBox(width: gap),
                                  Expanded(
                                    flex: 4,
                                    child: _ProjectDetails(
                                      project: project,
                                      fillAvailableHeight: false,
                                      onOpenLive: () =>
                                          _openLive(project!),
                                    ),
                                  ),
                                ],
                              );
                            }

                            final double mobileGalleryHeight =
                                ((constraints.maxWidth * 9 / 16) + 12)
                                    .clamp(260.0, 410.0)
                                    .toDouble();

                            return Column(
                              children: <Widget>[
                                SizedBox(
                                  height: mobileGalleryHeight,
                                  child: gallery,
                                ),
                                const SizedBox(height: 14),
                                _ProjectDetails(
                                  project: project,
                                  fillAvailableHeight: false,
                                  onOpenLive: () =>
                                      _openLive(project!),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
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

  void _move(
    ProjectModel project,
    int direction,
  ) {
    final length =
        project.images.isEmpty ? 1 : project.images.length;

    if (length <= 1) {
      return;
    }

    final next =
        (_pageIndex + direction + length) % length;

    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 560),
      curve: const Cubic(0.22, 1, 0.36, 1),
    );
  }

  Future<void> _openLive(
    ProjectModel project,
  ) async {
    final raw = project.liveUrl.trim();

    final uri = Uri.tryParse(
      raw.startsWith('http') ? raw : 'https://$raw',
    );

    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.title,
    required this.onBack,
    required this.onThemes,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onThemes;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: GlassSurface(
        radius: 26,
        opacity: 0.075,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        child: Row(
          children: <Widget>[
            IconButton.filled(
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor:
                    Colors.white.withOpacity(0.09),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'PROJECT VIEW',
                    style: TextStyle(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.7,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: 'Themes',
              onPressed: onThemes,
              icon: const Icon(Icons.palette_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectGallery extends StatelessWidget {
  const _ProjectGallery({
    required this.project,
    required this.pageController,
    required this.pageIndex,
    required this.onChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final ProjectModel project;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final count =
        project.images.isEmpty ? 1 : project.images.length;

    return AnimatedEntrance(
      delay: const Duration(milliseconds: 90),
      child: GlassSurface(
        radius: 38,
        opacity: 0.075,
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: count,
                  onPageChanged: onChanged,
                  itemBuilder: (context, index) {
                    if (project.images.isEmpty) {
                      return _EmptyGallery(
                        project: project,
                      );
                    }

                    final bytes =
                        project.images[index].decodeBytes();

                    if (bytes == null) {
                      return _EmptyGallery(
                        project: project,
                      );
                    }

                    return ColoredBox(
                      color: Colors.white.withOpacity(0.035),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Hero(
                          tag: index == 0
                              ? 'project-${project.id}'
                              : 'project-${project.id}-$index',
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            filterQuality:
                                FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (count > 1) ...<Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8),
                  child: _RoundControl(
                    icon: Icons.arrow_back_rounded,
                    onTap: onPrevious,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 8),
                  child: _RoundControl(
                    icon: Icons.arrow_forward_rounded,
                    onTap: onNext,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        List<Widget>.generate(
                      count,
                      (index) => AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 480),
                        curve:
                            const Cubic(0.22, 1, 0.36, 1),
                        width:
                            index == pageIndex ? 28 : 8,
                        height: 8,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(999),
                          color: index == pageIndex
                              ? AppColors.ink
                              : AppColors.ink
                                  .withOpacity(0.18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-${project.id}',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFFFF3E8),
              Color(0xFFFFC79F),
              Color(0xFFFF6B84),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Colors.white.withOpacity(0.10),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.orange,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  project.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add screenshots from Admin Control',
                  style: TextStyle(
                    color: AppColors.inkMuted,
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

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor:
            Colors.white.withOpacity(0.90),
        foregroundColor: AppColors.ink,
      ),
      icon: Icon(icon),
    );
  }
}

class _ProjectDetails extends StatelessWidget {
  const _ProjectDetails({
    required this.project,
    required this.onOpenLive,
    required this.fillAvailableHeight,
  });

  final ProjectModel project;
  final VoidCallback onOpenLive;
  final bool fillAvailableHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 150),
      child: GlassSurface(
        radius: 38,
        opacity: 0.085,
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact =
                fillAvailableHeight && constraints.maxHeight < 470;

            return Column(
              mainAxisSize: fillAvailableHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionEyebrow(
                  'Current project details',
                ),

                SizedBox(height: compact ? 10 : 14),

                Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                        fontSize: compact ? 38 : 44,
                        height: 1,
                      ),
                ),

                SizedBox(height: compact ? 12 : 16),

                Text(
                  project.details.isEmpty
                      ? 'No project details have been added yet.'
                      : project.details,
                  maxLines: compact ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: compact ? 14 : 15,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: compact ? 14 : 18),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 12 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.34),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _CompactProjectInfo(
                          icon: Icons.code_rounded,
                          label: 'Stack',
                          value: project.techStack,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.ink.withOpacity(0.08),
                      ),
                      Expanded(
                        child: _CompactProjectInfo(
                          icon: Icons.photo_library_outlined,
                          label: 'Screens',
                          value: '${project.images.length}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.ink.withOpacity(0.08),
                      ),
                      Expanded(
                        child: _CompactProjectInfo(
                          icon: Icons.public_rounded,
                          label: 'Status',
                          value: project.liveUrl.trim().isEmpty
                              ? 'Preview'
                              : 'Live',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: compact ? 12 : 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MetaPill(
                      icon: Icons.schedule_rounded,
                      text: project.createdAt,
                    ),
                    _MetaPill(
                      icon: Icons.photo_library_outlined,
                      text:
                          '${project.images.length} screenshots',
                    ),
                  ],
                ),

                if (fillAvailableHeight)
                  const Spacer()
                else
                  const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    label: 'Open Live Project',
                    icon: Icons.open_in_new_rounded,
                    primary: true,
                    onPressed: onOpenLive,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompactProjectInfo extends StatelessWidget {
  const _CompactProjectInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 17,
            color: AppColors.orange,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.inkMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ProjectSnapshot extends StatelessWidget {
  const _ProjectSnapshot({
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final bool hasLiveProject =
        project.liveUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.dashboard_customize_outlined,
                size: 18,
                color: AppColors.orange,
              ),
              SizedBox(width: 8),
              Text(
                'PROJECT SNAPSHOT',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth =
                  (constraints.maxWidth - 10) / 2;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: _SnapshotItem(
                      icon: Icons.layers_outlined,
                      label: 'Technology',
                      value: project.techStack,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _SnapshotItem(
                      icon: Icons.photo_library_outlined,
                      label: 'Project media',
                      value: project.images.isEmpty
                          ? 'No screenshots'
                          : '${project.images.length} screenshots',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _SnapshotItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Added on',
                      value: project.createdAt,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _SnapshotItem(
                      icon: hasLiveProject
                          ? Icons.public_rounded
                          : Icons.visibility_outlined,
                      label: 'Availability',
                      value: hasLiveProject
                          ? 'Live project'
                          : 'Preview only',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  const _SnapshotItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 72,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.50),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 15,
            color: AppColors.cyan,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.inkMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
