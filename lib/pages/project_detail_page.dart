import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
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
                    radius: AuraBento.radiusXl,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AuraBento.textTertiary,
                        ),
                        const SizedBox(height: AuraBento.space3),
                        const Text(
                          'Project not found',
                          style: TextStyle(
                            fontFamily: AuraBento.fontSerif,
                            fontSize: 26,
                            color: AuraBento.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AuraBento.space4),
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
                        const SizedBox(height: AuraBento.space3),
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
                              const double gap = AuraBento.cardGapDesktop;

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
                                const SizedBox(
                                    height: AuraBento.space3 + 2),
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
        radius: AuraBento.radiusMd + 6,
        padding: const EdgeInsets.symmetric(
          horizontal: AuraBento.space4 + 2,
          vertical: AuraBento.space2 + 2,
        ),
        child: Row(
          children: <Widget>[
            AuraCircularToken(
              icon: Icons.arrow_back_rounded,
              variant: AuraCircularTokenVariant.pitchBlack,
              tooltip: 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: AuraBento.space3),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'PROJECT VIEW',
                    style: TextStyle(
                      color: AuraBento.textTertiary,
                      fontWeight: FontWeight.w600,
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
                      color: AuraBento.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            AuraCircularToken(
              icon: Icons.palette_outlined,
              variant: AuraCircularTokenVariant.pureWhite,
              tooltip: 'Themes',
              onTap: onThemes,
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
        radius: AuraBento.radiusLg + 2,
        padding: const EdgeInsets.all(AuraBento.space2 + 2),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AuraBento.innerRadius(
                      AuraBento.radiusLg + 2, AuraBento.space2 + 2),
                ),
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
                      color: AuraBento.canvasLightSecondary,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AuraBento.space2 - 2),
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
                      const EdgeInsets.only(left: AuraBento.space2),
                  child: AuraCircularToken(
                    icon: Icons.arrow_back_rounded,
                    variant: AuraCircularTokenVariant.pureWhite,
                    tooltip: 'Previous screenshot',
                    onTap: onPrevious,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: AuraBento.space2),
                  child: AuraCircularToken(
                    icon: Icons.arrow_forward_rounded,
                    variant: AuraCircularTokenVariant.pureWhite,
                    tooltip: 'Next screenshot',
                    onTap: onNext,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: AuraBento.space3 + 2),
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
                              ? AuraBento.accentBlueAction
                              : AuraBento.textPrimary
                                  .withAlpha(36),
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
              Color(0xFFFFF1E8),
              Color(0xFFFFC9A8),
              Color(0xFFB9C0FF),
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
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AuraBento.surfaceWhite.withAlpha(210),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AuraBento.accentOrange,
                    size: 38,
                  ),
                ),
                const SizedBox(height: AuraBento.space4),
                Text(
                  project.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AuraBento.fontSerif,
                    color: AuraBento.textPrimary,
                    fontSize: 26,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AuraBento.space2),
                const Text(
                  'Add screenshots from Admin Control',
                  style: TextStyle(
                    color: AuraBento.textSecondary,
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
        radius: AuraBento.radiusLg + 2,
        padding: const EdgeInsets.all(AuraBento.space5 + 2),
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
                  style: TextStyle(
                    fontFamily: AuraBento.fontSerif,
                    color: AuraBento.textPrimary,
                    fontSize: compact ? 34 : 40,
                    height: 1.05,
                    letterSpacing: -0.4,
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
                    color: AuraBento.textSecondary,
                    fontSize: compact ? 13 : 14,
                    height: 1.55,
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
                    color: AuraBento.canvasLightSecondary,
                    borderRadius:
                        BorderRadius.circular(AuraBento.radiusMd),
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
                        color:
                            AuraBento.surfacePillNeutralSolid,
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
                        color:
                            AuraBento.surfacePillNeutralSolid,
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
                  spacing: AuraBento.space2,
                  runSpacing: AuraBento.space2,
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
                  const SizedBox(height: AuraBento.space4),

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
      padding: const EdgeInsets.symmetric(horizontal: AuraBento.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 17,
            color: AuraBento.accentBlueAction,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AuraBento.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
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
              color: AuraBento.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
        color: AuraBento.surfaceWhite,
        borderRadius:
            BorderRadius.circular(AuraBento.radiusFull),
        border: Border.all(color: AuraBento.surfacePillNeutralSolid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 15,
            color: AuraBento.accentBlueAction,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AuraBento.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
