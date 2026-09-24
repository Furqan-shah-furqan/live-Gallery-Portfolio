import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
import '../models/project_model.dart';
import '../services/project_store.dart';
import '../widgets/animated_mesh_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/project_card.dart';
import 'admin_access.dart';
import 'project_detail_page.dart';
import 'theme_page.dart';
import '../widgets/liquid_gooey.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _stack = 'All';

  @override
  void dispose() {
    _searchController.dispose();
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
                currentIndex: 1,
                onTapIndex: (index) {
                  if (index == 0) {
                    Navigator.of(context).pop();
                  } else if (index == 2) {
                    Navigator.of(context).push(
                      PremiumPageRoute<void>(page: const ThemePage()),
                    );
                  } else if (index == 3) {
                    openProtectedAdmin(context);
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
              final stacks = <String>{
                'All',
                ...store.projects.map((project) => project.techStack),
              }.toList();
              if (!stacks.contains(_stack)) _stack = 'All';

              final filtered = store.projects.where((project) {
                final matchesQuery = _query.isEmpty ||
                    project.name.toLowerCase().contains(_query.toLowerCase()) ||
                    project.details.toLowerCase().contains(_query.toLowerCase()) ||
                    project.techStack.toLowerCase().contains(_query.toLowerCase());
                final matchesStack = _stack == 'All' || project.techStack == _stack;
                return matchesQuery && matchesStack;
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _ProjectsHeader(
                          total: store.count,
                          onBack: () => Navigator.of(context).pop(),
                          onAdmin: () => openProtectedAdmin(context),
                          onThemes: () {
                            Navigator.of(context).push(
                              PremiumPageRoute<void>(
                                page: const ThemePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AuraBento.space5),
                        AnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                          child: GlassSurface(
                            radius: AuraBento.radiusXl,
                            padding: const EdgeInsets.all(AuraBento.space6 + 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SectionEyebrow('Explore live work'),
                                const SizedBox(height: AuraBento.space3),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final titleSize =
                                        constraints.maxWidth < 600 ? 36.0 : 50.0;
                                    return Text(
                                      'Every project in one focused gallery.',
                                      style: TextStyle(
                                        fontFamily: AuraBento.fontSerif,
                                        color: AuraBento.textPrimary,
                                        fontSize: titleSize,
                                        height: 1.08,
                                        letterSpacing: -0.4,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: AuraBento.space3),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 760),
                                  child: const Text(
                                    'Open any card to view every screenshot, project details, technology stack, and the live product link.',
                                    style: TextStyle(
                                      color: AuraBento.textSecondary,
                                      fontSize: 15,
                                      height: 1.65,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AuraBento.space6),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final narrow = constraints.maxWidth < 720;
                                    final search = TextField(
                                      controller: _searchController,
                                      onChanged: (value) =>
                                          setState(() => _query = value.trim()),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Search projects, tools, or technology',
                                        prefixIcon:
                                            Icon(Icons.search_rounded),
                                      ),
                                    );
                                    final filter = DropdownButtonFormField<String>(
                                      value: _stack,
                                      dropdownColor: AuraBento.surfaceWhite,
                                      decoration: const InputDecoration(
                                        prefixIcon:
                                            Icon(Icons.filter_alt_outlined),
                                      ),
                                      items: stacks
                                          .map(
                                            (stack) => DropdownMenuItem<String>(
                                              value: stack,
                                              child: Text(
                                                stack,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _stack = value);
                                        }
                                      },
                                    );

                                    if (narrow) {
                                      return Column(
                                        children: <Widget>[
                                          search,
                                          const SizedBox(
                                              height: AuraBento.space3),
                                          filter,
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: <Widget>[
                                        Expanded(flex: 3, child: search),
                                        const SizedBox(
                                            width: AuraBento.space3),
                                        Expanded(flex: 2, child: filter),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: AuraBento.space4),
                                LiquidGooeyBar<String>(
                                  items: stacks,
                                  selected: _stack,
                                  onSelected: (val) =>
                                      setState(() => _stack = val),
                                  labelBuilder: (s) => s,
                                  iconBuilder: (s) => s == 'All'
                                      ? Icons.apps_rounded
                                      : Icons.code_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AuraBento.space5),
                        if (filtered.isEmpty)
                          _NoProjects(
                            hasAnyProjects: store.projects.isNotEmpty,
                            onClearFilter: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _stack = 'All';
                              });
                            },
                            onAdmin: () => openProtectedAdmin(context),
                          )
                        else
                          _ProjectsGrid(
                            projects: filtered,
                            onOpen: (project) {
                              Navigator.of(context).push(
                                PremiumPageRoute<void>(
                                  page:
                                      ProjectDetailPage(projectId: project.id),
                                ),
                              );
                            },
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
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader({
    required this.total,
    required this.onBack,
    required this.onAdmin,
    required this.onThemes,
  });

  final int total;
  final VoidCallback onBack;
  final VoidCallback onAdmin;
  final VoidCallback onThemes;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: GlassSurface(
        radius: AuraBento.radiusMd + 5,
        padding: const EdgeInsets.symmetric(
          horizontal: AuraBento.space4 + 2,
          vertical: AuraBento.space3 + 2,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'ALL LIVE PROJECTS',
                    style: TextStyle(
                      color: AuraBento.textTertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$total systems available in this gallery',
                    style: const TextStyle(
                      color: AuraBento.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            LiquidGooeyButton(
              label: 'Themes',
              icon: Icons.palette_outlined,
              compact: true,
              onPressed: onThemes,
            ),
            const SizedBox(width: AuraBento.space2),
            LiquidGooeyButton(
              label: 'Admin',
              icon: Icons.admin_panel_settings_outlined,
              compact: true,
              onPressed: onAdmin,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid({required this.projects, required this.onOpen});

  final List<ProjectModel> projects;
  final ValueChanged<ProjectModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 160),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760 ? 2 : 1;
          const spacing = AuraBento.cardGapDesktop;
          final width = (constraints.maxWidth - (columns - 1) * spacing) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List<Widget>.generate(
              projects.length,
              (index) => SizedBox(
                width: width,
                child: AnimatedEntrance(
                  delay: Duration(milliseconds: 70 * index),
                  child: ProjectCard(
                    project: projects[index],
                    onTap: () => onOpen(projects[index]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoProjects extends StatelessWidget {
  const _NoProjects({
    required this.hasAnyProjects,
    required this.onClearFilter,
    required this.onAdmin,
  });

  final bool hasAnyProjects;
  final VoidCallback onClearFilter;
  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: GlassSurface(
        radius: AuraBento.radiusLg + 6,
        padding: const EdgeInsets.all(44),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuraBento.canvasLightSecondary,
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 28,
                  color: AuraBento.accentBlueAction,
                ),
              ),
              const SizedBox(height: AuraBento.space4),
              Text(
                hasAnyProjects
                    ? 'No matching project found'
                    : 'No Projects added Yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AuraBento.fontSerif,
                  color: AuraBento.textPrimary,
                  fontSize: 30,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AuraBento.space2),
              Text(
                hasAnyProjects
                    ? 'Clear the current search and filter to see the complete gallery.'
                    : 'Open Admin Control and add your first live project.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AuraBento.textSecondary),
              ),
              const SizedBox(height: AuraBento.space5),
              PremiumButton(
                label: hasAnyProjects ? 'Clear Filters' : 'Open Admin Control',
                primary: true,
                onPressed: hasAnyProjects ? onClearFilter : onAdmin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
