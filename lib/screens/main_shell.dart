import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import 'feed_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'add_project_screen.dart';
import 'github_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _isLoading = true;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.loadProjects();
    if (mounted) {
      setState(() {
        _projects = data;
        _isLoading = false;
      });
    }
  }

  void _addProject(Project p) {
    setState(() => _projects.insert(0, p));
    StorageService.saveProjects(_projects);
  }

  void _toggleStar(String id) {
    setState(() {
      final idx = _projects.indexWhere((p) => p.id == id);
      if (idx == -1) return;
      final p = _projects[idx];
      _projects[idx] = p.copyWith(
        isStarred: !p.isStarred,
        stars: p.isStarred ? p.stars - 1 : p.stars + 1,
      );
    });
    StorageService.saveProjects(_projects);
  }

  void _deleteProject(String id) {
    setState(() => _projects.removeWhere((p) => p.id == id));
    StorageService.saveProjects(_projects);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      FeedScreen(
        projects: _projects,
        onToggleStar: _toggleStar,
        onDelete: _deleteProject,
      ),
      AnalyticsScreen(projects: _projects),
      const GitHubScreen(),
      ProfileScreen(projectCount: _projects.length),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_outlined),
            selectedIcon: Icon(Icons.code_rounded),
            label: 'GitHub',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push<Project>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddProjectScreen()),
                );
                if (result != null) _addProject(result);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Project'),
            )
          : null,
    );
  }
}