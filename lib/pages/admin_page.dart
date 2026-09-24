import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
import '../models/project_model.dart';
import '../services/project_store.dart';
import '../widgets/animated_mesh_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/liquid_gooey.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';
import 'projects_page.dart';
import 'theme_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final PageController _latestController = PageController(viewportFraction: 0.92);
  int _latestIndex = 0;
  bool _manageMode = false;

  @override
  void dispose() {
    _latestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ProjectStoreScope.of(context);

    return AnimatedMeshBackground(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Center(
              heightFactor: 1.0,
              child: LiquidGooeyDock(
                currentIndex: 3,
                onTapIndex: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      PremiumPageRoute<void>(page: const ProjectsPage()),
                    );
                  } else if (index == 2) {
                    Navigator.of(context).pushReplacement(
                      PremiumPageRoute<void>(page: const ThemePage()),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              if (_latestIndex >= store.count && store.count > 0) {
                _latestIndex = 0;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _AdminHeader(
                          projectCount: store.count,
                          manageMode: _manageMode,
                          onBack: () => Navigator.of(context).pop(),
                          onDashboard: () => setState(() => _manageMode = false),
                          onManage: () => setState(() => _manageMode = true),
                          onAdd: () => _addProject(context, store),
                        ),
                        const SizedBox(height: AuraBento.space5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 560),
                          switchInCurve: const Cubic(0.22, 1, 0.36, 1),
                          switchOutCurve: const Cubic(0.22, 1, 0.36, 1),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.025),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _manageMode
                              ? _ManageProjectsView(
                                  key: const ValueKey<String>('manage'),
                                  projects: store.projects,
                                  onOpen: (project) => _openProject(context, project),
                                  onDelete: (project) =>
                                      _deleteProject(context, store, project),
                                  onClear: () => _clearAll(context, store),
                                  onRestore: () => _restore(context, store),
                                  onAdd: () => _addProject(context, store),
                                )
                              : _DashboardView(
                                  key: const ValueKey<String>('dashboard'),
                                  projects: store.projects,
                                  pageController: _latestController,
                                  pageIndex: _latestIndex,
                                  onPageChanged: (value) =>
                                      setState(() => _latestIndex = value),
                                  onOpen: (project) => _openProject(context, project),
                                  onAdd: () => _addProject(context, store),
                                  onManage: () => setState(() => _manageMode = true),
                                ),
                        ),
                        const SizedBox(height: AuraBento.space5),
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

  Future<void> _addProject(BuildContext context, ProjectStore store) async {
    final project = await showGeneralDialog<ProjectModel>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Add Project',
      barrierColor: Colors.black.withAlpha(66),
      transitionDuration: const Duration(milliseconds: 560),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _AddProjectDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.22, 1, 0.36, 1),
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );

    if (project == null || !mounted) return;

    try {
      await store.addProject(project);
      if (!mounted) return;
      setState(() {
        _manageMode = false;
        _latestIndex = 0;
      });
      _showMessage(context, 'Project added successfully.', success: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        context,
        'The project could not be saved. Use smaller screenshots or clear old projects.',
        success: false,
      );
    }
  }

  Future<void> _deleteProject(
    BuildContext context,
    ProjectStore store,
    ProjectModel project,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete project?',
      message: 'This will permanently remove “${project.name}” from this device.',
      confirmLabel: 'Delete Project',
    );
    if (!confirmed || !mounted) return;

    await store.deleteProject(project.id);
    if (!mounted) return;
    _showMessage(context, 'Project deleted successfully.', success: true);
  }

  Future<void> _clearAll(BuildContext context, ProjectStore store) async {
    final confirmed = await _confirm(
      context,
      title: 'Clear all projects?',
      message:
          'Every project and locally stored screenshot will be removed from this device.',
      confirmLabel: 'Clear Everything',
    );
    if (!confirmed || !mounted) return;

    await store.clearProjects();
    if (!mounted) return;
    _showMessage(context, 'All projects were removed.', success: true);
  }

  Future<void> _restore(BuildContext context, ProjectStore store) async {
    await store.restoreStarterProjects();
    if (!mounted) return;
    _showMessage(context, 'Starter portfolio projects restored.', success: true);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AuraBento.surfaceWhite,
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: AuraBento.fontSerif,
                  color: AuraBento.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(color: AuraBento.textSecondary),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AuraBento.textInverted,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AuraBento.radiusFull),
                    ),
                  ),
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _openProject(BuildContext context, ProjectModel project) {
    Navigator.of(context).push(
      PremiumPageRoute<void>(
        page: ProjectDetailPage(projectId: project.id),
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    required bool success,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: success
                    ? AuraBento.accentBlueAction
                    : const Color(0xFFFF8FAE),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AuraBento.textInverted),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.projectCount,
    required this.manageMode,
    required this.onBack,
    required this.onDashboard,
    required this.onManage,
    required this.onAdd,
  });

  final int projectCount;
  final bool manageMode;
  final VoidCallback onBack;
  final VoidCallback onDashboard;
  final VoidCallback onManage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: GlassSurface(
        radius: AuraBento.radiusMd + 8,
        padding: const EdgeInsets.all(AuraBento.space4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;
            final title = Row(
              children: <Widget>[
                AuraCircularToken(
                  icon: Icons.arrow_back_rounded,
                  variant: AuraCircularTokenVariant.pitchBlack,
                  tooltip: 'Back to portfolio',
                  onTap: onBack,
                ),
                const SizedBox(width: AuraBento.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'ADMIN CONTROL',
                        style: TextStyle(
                          color: AuraBento.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$projectCount live projects saved on this device',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AuraBento.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actions = Wrap(
              spacing: 9,
              runSpacing: 9,
              alignment: WrapAlignment.end,
              children: <Widget>[
                PremiumButton(
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  compact: true,
                  primary: !manageMode,
                  onPressed: onDashboard,
                ),
                PremiumButton(
                  label: 'All Projects',
                  icon: Icons.grid_view_rounded,
                  compact: true,
                  primary: manageMode,
                  onPressed: onManage,
                ),
                PremiumButton(
                  label: 'Add Project',
                  icon: Icons.add_rounded,
                  compact: true,
                  onPressed: onAdd,
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  title,
                  const SizedBox(height: AuraBento.space3 + 2),
                  actions,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: title),
                const SizedBox(width: AuraBento.space4 + 2),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    super.key,
    required this.projects,
    required this.pageController,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onOpen,
    required this.onAdd,
    required this.onManage,
  });

  final List<ProjectModel> projects;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ProjectModel> onOpen;
  final VoidCallback onAdd;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final screenshotCount = projects.fold<int>(
      0,
      (total, project) => total + project.images.length,
    );
    final stacks = projects.map((project) => project.techStack).toSet().length;

    return Column(
      children: <Widget>[
        AnimatedEntrance(
          delay: const Duration(milliseconds: 80),
          child: GlassSurface(
            radius: AuraBento.radiusXl,
            padding: const EdgeInsets.all(AuraBento.space8 - 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SectionEyebrow('Portfolio operations'),
                    const SizedBox(height: AuraBento.space3 + 1),
                    Text(
                      'Manage every live system from one clean dashboard.',
                      style: TextStyle(
                        fontFamily: AuraBento.fontSerif,
                        color: AuraBento.textPrimary,
                        fontSize: constraints.maxWidth < 600 ? 34 : 46,
                        height: 1.08,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AuraBento.space3 + 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: const Text(
                        'Add project details, multiple screenshots, the technology stack, and a live link. Changes appear in the public project gallery automatically.',
                        style: TextStyle(
                          color: AuraBento.textSecondary,
                          fontSize: 15,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                );
                final actions = Wrap(
                  spacing: AuraBento.space2 + 2,
                  runSpacing: AuraBento.space2 + 2,
                  children: <Widget>[
                    PremiumButton(
                      label: 'Add New Live Project',
                      icon: Icons.add_photo_alternate_outlined,
                      primary: true,
                      onPressed: onAdd,
                    ),
                    PremiumButton(
                      label: 'Manage All',
                      icon: Icons.tune_rounded,
                      onPressed: onManage,
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
                    const SizedBox(width: AuraBento.space6),
                    actions,
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AuraBento.space5),
        _AdminStats(
          projects: projects.length,
          screenshots: screenshotCount,
          stacks: stacks,
        ),
        const SizedBox(height: AuraBento.space5),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 180),
          child: GlassSurface(
            radius: AuraBento.radiusLg + 2,
            padding: const EdgeInsets.all(AuraBento.space5 + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                        child: SectionEyebrow('Latest project slider')),
                    Text(
                      projects.isEmpty
                          ? 'No projects'
                          : '${pageIndex + 1} / ${projects.length}',
                      style: const TextStyle(
                        color: AuraBento.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AuraBento.space4 + 2),
                if (projects.isEmpty)
                  _AdminEmptyState(onAdd: onAdd)
                else ...<Widget>[
                  SizedBox(
                    height: 430,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: projects.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: ProjectCard(
                            project: projects[index],
                            onTap: () => onOpen(projects[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AuraBento.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      projects.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 480),
                        curve: const Cubic(0.22, 1, 0.36, 1),
                        width: index == pageIndex ? 30 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == pageIndex
                              ? AuraBento.accentBlueAction
                              : AuraBento.textPrimary.withAlpha(30),
                          borderRadius:
                              BorderRadius.circular(AuraBento.radiusFull),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStats extends StatelessWidget {
  const _AdminStats({
    required this.projects,
    required this.screenshots,
    required this.stacks,
  });

  final int projects;
  final int screenshots;
  final int stacks;

  @override
  Widget build(BuildContext context) {
    final stats = <({String value, String label, IconData icon})>[
      (
        value: '$projects',
        label: 'Live projects',
        icon: Icons.grid_view_rounded
      ),
      (
        value: '$screenshots',
        label: 'Screenshots',
        icon: Icons.photo_library_outlined
      ),
      (
        value: '$stacks',
        label: 'Technology stacks',
        icon: Icons.code_rounded
      ),
      (
        value: 'Local',
        label: 'Private storage',
        icon: Icons.lock_outline_rounded
      ),
    ];

    return AnimatedEntrance(
      delay: const Duration(milliseconds: 130),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;
          final width =
              (constraints.maxWidth - (columns - 1) * 14) / columns;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: stats
                .map(
                  (stat) => SizedBox(
                    width: width,
                    child: GlassSurface(
                      radius: AuraBento.radiusLg - 2,
                      padding: const EdgeInsets.all(AuraBento.space5),
                      shadow: false,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AuraBento.badgeLavenderBg,
                            ),
                            child: Icon(stat.icon,
                                color: AuraBento.badgeLavenderText),
                          ),
                          const SizedBox(width: AuraBento.space3 + 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  stat.value,
                                  style: const TextStyle(
                                    color: AuraBento.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  stat.label,
                                  style: const TextStyle(
                                    color: AuraBento.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _ManageProjectsView extends StatelessWidget {
  const _ManageProjectsView({
    super.key,
    required this.projects,
    required this.onOpen,
    required this.onDelete,
    required this.onClear,
    required this.onRestore,
    required this.onAdd,
  });

  final List<ProjectModel> projects;
  final ValueChanged<ProjectModel> onOpen;
  final ValueChanged<ProjectModel> onDelete;
  final VoidCallback onClear;
  final VoidCallback onRestore;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedEntrance(
          child: GlassSurface(
            radius: AuraBento.radiusLg,
            padding: const EdgeInsets.all(AuraBento.space6 + 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SectionEyebrow('All projects'),
                    const SizedBox(height: AuraBento.space3),
                    Text(
                      'Manage the complete live gallery.',
                      style: TextStyle(
                        fontFamily: AuraBento.fontSerif,
                        color: AuraBento.textPrimary,
                        fontSize: constraints.maxWidth < 600 ? 34 : 44,
                        height: 1.08,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AuraBento.space2 + 2),
                    Text(
                      '${projects.length} projects currently saved on this device.',
                      style: const TextStyle(
                        color: AuraBento.textSecondary,
                      ),
                    ),
                  ],
                );
                final actions = Wrap(
                  spacing: AuraBento.space2 + 2,
                  runSpacing: AuraBento.space2 + 2,
                  children: <Widget>[
                    PremiumButton(
                      label: 'Add Project',
                      icon: Icons.add_rounded,
                      primary: true,
                      onPressed: onAdd,
                    ),
                    if (projects.isNotEmpty)
                      PremiumButton(
                        label: 'Clear All',
                        icon: Icons.delete_sweep_outlined,
                        danger: true,
                        onPressed: onClear,
                      ),
                    if (projects.isEmpty)
                      PremiumButton(
                        label: 'Restore Starter Projects',
                        icon: Icons.restore_rounded,
                        onPressed: onRestore,
                      ),
                  ],
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      copy,
                      const SizedBox(height: AuraBento.space5),
                      actions,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: copy),
                    const SizedBox(width: AuraBento.space5),
                    actions,
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AuraBento.space5),
        if (projects.isEmpty)
          _AdminEmptyState(onAdd: onAdd, onRestore: onRestore)
        else
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 2 : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 20) / columns;
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: projects
                      .map(
                        (project) => SizedBox(
                          width: width,
                          child: ProjectCard(
                            project: project,
                            onTap: () => onOpen(project),
                            deleteAction: () => onDelete(project),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState({required this.onAdd, this.onRestore});

  final VoidCallback onAdd;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AuraBento.radiusLg - 2,
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AuraBento.badgeAmberBg,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AuraBento.badgeAmberText,
                size: 28,
              ),
            ),
            const SizedBox(height: AuraBento.space4),
            const Text(
              'No project added yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AuraBento.fontSerif,
                color: AuraBento.textPrimary,
                fontSize: 30,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AuraBento.space2 + 2),
            const Text(
              'Add project details and screenshots to publish them in the live gallery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraBento.textSecondary),
            ),
            const SizedBox(height: AuraBento.space5 + 2),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                PremiumButton(
                  label: 'Add New Project',
                  icon: Icons.add_rounded,
                  primary: true,
                  onPressed: onAdd,
                ),
                if (onRestore != null)
                  PremiumButton(
                    label: 'Restore Starter Projects',
                    icon: Icons.restore_rounded,
                    onPressed: onRestore,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProjectDialog extends StatefulWidget {
  const _AddProjectDialog();

  @override
  State<_AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<_AddProjectDialog> {
  static const List<String> _techOptions = <String>[
    'Flutter + Supabase',
    'Flutter',
    'Flutter + Firebase',
    'Next.js + Tailwind CSS',
    'React + Next.js',
    'JavaScript',
    'Firebase',
    'Supabase',
    'HTML + CSS',
    'Web Tools',
    'AI + Web App',
    'Custom Stack',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(
    text: 'https://smart-account-manager-five.vercel.app/',
  );
  final List<_PickedImage> _images = <_PickedImage>[];

  String _techStack = _techOptions.first;
  String? _error;
  bool _picking = false;

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 780, maxHeight: 820),
            child: Material(
              color: Colors.transparent,
              child: GlassSurface(
                radius: AuraBento.radiusXl,
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AuraBento.space6 + 2),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Add New Live Project',
                                    style: TextStyle(
                                      fontFamily: AuraBento.fontSerif,
                                      color: AuraBento.textPrimary,
                                      fontSize: 30,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Add project information and up to eight screenshots. Everything is stored locally on this device.',
                                    style: TextStyle(
                                      color: AuraBento.textSecondary,
                                      height: 1.5,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AuraBento.space3),
                            AuraCircularToken(
                              icon: Icons.close_rounded,
                              variant:
                                  AuraCircularTokenVariant.pureWhite,
                              tooltip: 'Close',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: AuraBento.space6),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact =
                                constraints.maxWidth < 620;
                            final name = TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Project name',
                                hintText: 'Type your project name',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Project name is required.';
                                }
                                return null;
                              },
                            );
                            final tech = DropdownButtonFormField<String>(
                              value: _techStack,
                              dropdownColor: AuraBento.surfaceWhite,
                              decoration: const InputDecoration(
                                labelText: 'Tech stack',
                              ),
                              items: _techOptions
                                  .map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _techStack = value);
                                }
                              },
                            );

                            if (compact) {
                              return Column(
                                children: <Widget>[
                                  name,
                                  const SizedBox(
                                      height: AuraBento.space3 + 1),
                                  tech,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: name),
                                const SizedBox(
                                    width: AuraBento.space3 + 1),
                                Expanded(child: tech),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AuraBento.space3 + 1),
                        TextFormField(
                          controller: _detailsController,
                          minLines: 4,
                          maxLines: 7,
                          decoration: const InputDecoration(
                            labelText: 'Project details',
                            hintText:
                                'Explain the problem, workflow, and useful features',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Project details are required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AuraBento.space3 + 1),
                        TextFormField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            labelText: 'Project live link',
                            hintText: 'https://example.vercel.app/',
                          ),
                          validator: (value) {
                            final raw = value?.trim() ?? '';
                            final normalized =
                                raw.startsWith('http') ? raw : 'https://$raw';
                            final uri = Uri.tryParse(normalized);
                            if (raw.isEmpty ||
                                uri == null ||
                                !uri.hasAuthority) {
                              return 'Add a valid live project link.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AuraBento.space4),
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(AuraBento.radiusMd + 6),
                          onTap: _picking ? null : _pickImages,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AuraBento.space5,
                              vertical: AuraBento.space6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AuraBento.radiusMd + 6),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFFF6F7FA),
                                  Color(0xFFEAF1FF),
                                ],
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  _picking
                                      ? Icons.hourglass_top_rounded
                                      : Icons.add_photo_alternate_outlined,
                                  color: AuraBento.accentBlueAction,
                                  size: 32,
                                ),
                                const SizedBox(
                                    height: AuraBento.space2 + 2),
                                Text(
                                  _picking
                                      ? 'Reading screenshots…'
                                      : 'Choose project screenshots',
                                  style: const TextStyle(
                                    color: AuraBento.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'PNG, JPG, or WEBP · maximum 2MB each · up to 8 images',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AuraBento.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_images.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AuraBento.space3 + 2),
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final image = _images[index];
                                return Stack(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AuraBento.radiusSm + 4),
                                      child: Container(
                                        width: 132,
                                        height: 96,
                                        color: AuraBento
                                            .canvasLightSecondary,
                                        child: Image.memory(
                                          image.bytes,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() =>
                                              _images.removeAt(index));
                                        },
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration:
                                              const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                AuraBento.surfaceWhite,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 15,
                                            color:
                                                AuraBento.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        if (_error != null) ...<Widget>[
                          const SizedBox(
                              height: AuraBento.space3),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: AuraBento.space5 + 2),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            PremiumButton(
                              label: 'Save Project',
                              icon: Icons.check_rounded,
                              primary: true,
                              onPressed: _submit,
                            ),
                            PremiumButton(
                              label: 'Cancel',
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;

      if (_images.length + result.files.length > 8) {
        setState(
            () => _error = 'You can upload a maximum of 8 screenshots.');
        return;
      }

      for (final file in result.files) {
        if (file.size > 2 * 1024 * 1024) {
          setState(() => _error = '${file.name} is larger than 2MB.');
          return;
        }
        final bytes = file.bytes;
        if (bytes == null) {
          setState(() => _error = '${file.name} could not be read.');
          return;
        }
        _images.add(_PickedImage(name: file.name, bytes: bytes));
      }

      setState(() {});
    } catch (_) {
      setState(() =>
          _error = 'The selected screenshots could not be opened.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rawUrl = _urlController.text.trim();
    final liveUrl = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final now = DateTime.now();
    final createdAt =
        '${now.day.toString().padLeft(2, '0')} ${_month(now.month)} ${now.year}';

    final project = ProjectModel(
      id: '${_slug(_nameController.text)}-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      details: _detailsController.text.trim(),
      techStack: _techStack,
      liveUrl: liveUrl,
      createdAt: createdAt,
      images: _images
          .asMap()
          .entries
          .map(
            (entry) => ProjectImageData(
              id: 'image-${now.microsecondsSinceEpoch}-${entry.key}',
              name: entry.value.name,
              dataUrl: _asDataUrl(entry.value),
            ),
          )
          .toList(),
    );

    Navigator.of(context).pop(project);
  }

  String _asDataUrl(_PickedImage image) {
    final extension = image.name.split('.').last.toLowerCase();
    final mime = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    return 'data:$mime;base64,${base64Encode(image.bytes)}';
  }

  String _slug(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'project' : slug;
  }

  String _month(int month) {
    const values = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return values[month - 1];
  }
}

class _PickedImage {
  const _PickedImage({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
