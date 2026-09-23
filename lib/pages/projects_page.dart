import 'package:flutter/material.dart';

import '../core/app_theme.dart';
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
      darkness: 0.90,
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
                        const SizedBox(height: 20),
                        AnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                          child: GlassSurface(
                            radius: 45,
                            opacity: 0.065,
                            padding: const EdgeInsets.all(26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SectionEyebrow('Explore live work'),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final titleSize = constraints.maxWidth < 600 ? 42.0 : 66.0;
                                    return Text(
                                      'Every project in one focused gallery.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(fontSize: titleSize),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                 ConstrainedBox(
                                  constraints:const BoxConstraints(maxWidth: 760),
                                  child:const Text(
                                    'Open any card to view every screenshot, project details, technology stack, and the live product link.',
                                    style: TextStyle(
                                      color: AppColors.inkMuted,
                                      fontSize: 16,
                                      height: 1.65,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final narrow = constraints.maxWidth < 720;
                                    final search = TextField(
                                      controller: _searchController,
                                      onChanged: (value) => setState(() => _query = value.trim()),
                                      decoration: const InputDecoration(
                                        hintText: 'Search projects, tools, or technology',
                                        prefixIcon: Icon(Icons.search_rounded),
                                      ),
                                    );
                                    final filter = DropdownButtonFormField<String>(
                                      value: _stack,
                                      dropdownColor: Colors.white,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.filter_alt_outlined),
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
                                        if (value != null) setState(() => _stack = value);
                                      },
                                    );

                                    if (narrow) {
                                      return Column(
                                        children: <Widget>[
                                          search,
                                          const SizedBox(height: 12),
                                          filter,
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: <Widget>[
                                        Expanded(flex: 3, child: search),
                                        const SizedBox(width: 12),
                                        Expanded(flex: 2, child: filter),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 18),
                                LiquidGooeyBar<String>(
                                  items: stacks,
                                  selected: _stack,
                                  onSelected: (val) => setState(() => _stack = val),
                                  labelBuilder: (s) => s,
                                  iconBuilder: (s) =>
                                      s == 'All' ? Icons.apps_rounded : Icons.code_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                  page: ProjectDetailPage(projectId: project.id),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
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
        radius: 25,
        opacity: 0.075,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: <Widget>[
            IconButton.filled(
              tooltip: 'Back',
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.09),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'ALL LIVE PROJECTS',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$total systems available in this gallery',
                    style: const TextStyle(
                      color: AppColors.inkMuted,
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
            const SizedBox(width: 8),
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
          final spacing = 20.0;
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
        radius: 34,
        opacity: 0.07,
        padding: const EdgeInsets.all(44),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.grid_view_rounded,
                size: 52,
                color: AppColors.cyan,
              ),
              const SizedBox(height: 18),
              Text(
                hasAnyProjects ? 'No matching project found' : 'No Projects added Yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                hasAnyProjects
                    ? 'Clear the current search and filter to see the complete gallery.'
                    : 'Open Admin Control and add your first live project.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 22),
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
