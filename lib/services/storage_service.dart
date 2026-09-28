import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class StorageService {
  static const String _projectsKey = 'devhub_v2_projects';
  static const String _themeKey = 'devhub_v2_theme';
  static const String _profileKey = 'devhub_v2_profile';
  static const String _onboardedKey = 'devhub_v2_onboarded';

  // ── Projects ──────────────────────────────────────────────────────────────

  static Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_projectsKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => Project.fromJson(e)).toList();
    }
    final seed = _seedProjects();
    await saveProjects(seed);
    return seed;
  }

  static Future<void> saveProjects(List<Project> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _projectsKey, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, val);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data != null && data.isNotEmpty) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    }
    return {
      'name': 'Pulkit',
      'bio': 'AI & ML student | Flutter Developer | Urban Mobility Researcher',
      'email': 'pulkit@devhub.app',
      'github': 'github.com/pulkit',
    };
  }

  static Future<void> saveProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  static Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
  }

  // ── Seed Data ─────────────────────────────────────────────────────────────

  static List<Project> _seedProjects() => [
        Project(
          id: 'PRJ-101',
          title: 'Cross-Platform Flutter Portal',
          description:
              'A multi-screen mobile app incorporating local state persistence, clean modular architecture, and dynamic category filtering with Provider state management.',
          techStack: 'Flutter, Dart, Provider, Shared Preferences',
          author: 'Pulkit',
          githubUrl: 'https://github.com',
          category: ProjectCategory.mobileApp,
          status: DevelopmentStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          stars: 18,
        ),
        Project(
          id: 'PRJ-102',
          title: 'AI Citizen Grievance Engine',
          description:
              'Transformer-based semantic classification pipeline for civic complaint categorization and resolution status tracking using BERT fine-tuning.',
          techStack: 'Python, PyTorch, Transformers, FastAPI, Docker',
          author: 'Pulkit',
          githubUrl: 'https://github.com',
          category: ProjectCategory.aiMl,
          status: DevelopmentStatus.inProgress,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          stars: 32,
        ),
        Project(
          id: 'PRJ-103',
          title: 'Mumbai Synthetic Population Engine',
          description:
              'Multi-stage pipeline generating a calibrated synthetic population for urban mobility modeling and policy simulation at ward level.',
          techStack: 'Python, Pandas, GeoPandas, NumPy, Matplotlib',
          author: 'Pulkit',
          githubUrl: 'https://github.com',
          category: ProjectCategory.dataScience,
          status: DevelopmentStatus.inProgress,
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          stars: 11,
        ),
        Project(
          id: 'PRJ-104',
          title: 'React Dashboard — GST Analytics',
          description:
              'Interactive business dashboard for GST filing analytics, ITC reconciliation, and vendor management built with React and Recharts.',
          techStack: 'React, TypeScript, Recharts, Tailwind CSS, Vite',
          author: 'Pulkit',
          githubUrl: 'https://github.com',
          category: ProjectCategory.webDev,
          status: DevelopmentStatus.maintenance,
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          stars: 7,
        ),
      ];
}
