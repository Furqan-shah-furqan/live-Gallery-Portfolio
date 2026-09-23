import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/project_model.dart';
import 'project_persistence.dart';

class ProjectStore extends ChangeNotifier {
  static const String storageKey = 'live-systems-gallery-admin-projects';

  List<ProjectModel> _projects = <ProjectModel>[];
  bool _loaded = false;

  List<ProjectModel> get projects => List<ProjectModel>.unmodifiable(_projects);
  bool get loaded => _loaded;
  int get count => _projects.length;
  ProjectModel? get latestProject => _projects.isEmpty ? null : _projects.first;

  Future<void> load() async {
    final raw = await readProjectJson(storageKey);
    var hasValidSavedList = false;

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          hasValidSavedList = true;
          _projects = decoded
              .whereType<Map>()
              .map(
                (item) => ProjectModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      } catch (_) {
        _projects = <ProjectModel>[];
      }
    }

    if (!hasValidSavedList) {
      _projects = <ProjectModel>[];
      await _persistProjects(_projects);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> addProject(ProjectModel project) async {
    final nextProjects = <ProjectModel>[project, ..._projects];
    await _persistProjects(nextProjects);
    _projects = nextProjects;
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    final nextProjects =
        _projects.where((project) => project.id != id).toList();
    await _persistProjects(nextProjects);
    _projects = nextProjects;
    notifyListeners();
  }

  Future<void> clearProjects() async {
    final nextProjects = <ProjectModel>[];
    await _persistProjects(nextProjects);
    _projects = nextProjects;
    notifyListeners();
  }

  Future<void> restoreStarterProjects() async {
    final nextProjects = _starterProjects;
    await _persistProjects(nextProjects);
    _projects = nextProjects;
    notifyListeners();
  }

  Future<void> _persistProjects(List<ProjectModel> projects) async {
    final raw = jsonEncode(
      projects.map((project) => project.toJson()).toList(),
    );
    await writeProjectJson(storageKey, raw);
  }

  List<ProjectModel> get _starterProjects => <ProjectModel>[
        ProjectModel(
          id: 'dms-${DateTime.now().microsecondsSinceEpoch}',
          name: 'Distributor Management System',
          details:
              'A production-focused business system for distributors, parties, stock, primary receiving, deposits, payments, recovery tracking, and operational reporting.',
          techStack: 'Flutter + Supabase',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: 'Featured system',
          images: const <ProjectImageData>[],
        ),
        ProjectModel(
          id: 'downloader-${DateTime.now().microsecondsSinceEpoch + 1}',
          name: 'Multi-Platform Downloader',
          details:
              'A focused downloader experience designed for YouTube, Instagram, Facebook, TikTok, Pinterest, Dailymotion, Twitch, Reddit, and other media platforms.',
          techStack: 'Next.js + Web APIs',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: 'Web utility',
          images: const <ProjectImageData>[],
        ),
        ProjectModel(
          id: 'directory-${DateTime.now().microsecondsSinceEpoch + 2}',
          name: 'App Directory Platform',
          details:
              'A responsive app discovery directory with clear categories, product cards, store-oriented layouts, and scalable content organization.',
          techStack: 'Next.js + Tailwind CSS',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: 'Directory product',
          images: const <ProjectImageData>[],
        ),
        ProjectModel(
          id: 'pdf-${DateTime.now().microsecondsSinceEpoch + 3}',
          name: 'PDF Tools Collection',
          details:
              'A collection of practical PDF conversion and document utility tools designed around fast, simple, task-focused workflows.',
          techStack: 'Web Tools',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: '20+ tool concepts',
          images: const <ProjectImageData>[],
        ),
        ProjectModel(
          id: 'calculator-${DateTime.now().microsecondsSinceEpoch + 4}',
          name: 'Calculator Suite',
          details:
              'A growing suite of everyday calculators, including standard, weight, conversion, and purpose-built calculation experiences.',
          techStack: 'JavaScript + Responsive UI',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: '10+ calculators',
          images: const <ProjectImageData>[],
        ),
        ProjectModel(
          id: 'clipping-${DateTime.now().microsecondsSinceEpoch + 5}',
          name: 'Social Clipping Studio',
          details:
              'A creator tool for editing clip text, style, color, positioning, shadows, backgrounds, and preparing scheduled publishing workflows.',
          techStack: 'AI + Web App',
          liveUrl: 'https://smart-account-manager-five.vercel.app/',
          createdAt: 'Creator workflow',
          images: const <ProjectImageData>[],
        ),
      ];
}

class ProjectStoreScope extends InheritedNotifier<ProjectStore> {
  const ProjectStoreScope({
    super.key,
    required ProjectStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ProjectStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProjectStoreScope>();
    assert(scope != null, 'ProjectStoreScope was not found in the widget tree.');
    return scope!.notifier!;
  }

  static ProjectStore read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<ProjectStoreScope>();
    final scope = element?.widget as ProjectStoreScope?;
    assert(scope != null, 'ProjectStoreScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
