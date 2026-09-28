import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/github_service.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class GitHubScreen extends StatefulWidget {
  const GitHubScreen({super.key});

  @override
  State<GitHubScreen> createState() => _GitHubScreenState();
}

class _GitHubScreenState extends State<GitHubScreen> {
  final _usernameCtrl = TextEditingController(text: 'pulkit');
  List<GitHubRepo> _repos = [];
  Map<String, dynamic> _ghProfile = {};
  bool _loading = false;
  bool _hasFetched = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _hasFetched = false;
    });
    try {
      final results = await Future.wait([
        GitHubService.fetchRepos(username),
        GitHubService.fetchUserProfile(username),
      ]);
      if (!mounted) return;
      setState(() {
        _repos = results[0] as List<GitHubRepo>;
        _ghProfile = results[1] as Map<String, dynamic>;
        _loading = false;
        _hasFetched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _hasFetched = true;
      });
    }
  }

  Future<void> _importRepo(GitHubRepo repo) async {
    final projects = await StorageService.loadProjects();
    final alreadyExists = projects.any((p) => p.githubUrl == repo.url);
    if (alreadyExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${repo.name}" is already in your projects!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final newProject = Project(
      id: 'GH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: repo.name.replaceAll('-', ' ').replaceAll('_', ' '),
      description: repo.description,
      techStack: repo.language,
      author: _usernameCtrl.text.trim(),
      githubUrl: repo.url,
      category: _guessCategory(repo.language),
      status: DevelopmentStatus.completed,
      timestamp: DateTime.tryParse(repo.updatedAt) ?? DateTime.now(),
      stars: repo.stars,
    );

    projects.insert(0, newProject);
    await StorageService.saveProjects(projects);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "${newProject.title}" imported to your projects!'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ProjectCategory _guessCategory(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return ProjectCategory.aiMl;
      case 'dart':
      case 'kotlin':
      case 'swift':
        return ProjectCategory.mobileApp;
      case 'javascript':
      case 'typescript':
      case 'html':
      case 'css':
        return ProjectCategory.webDev;
      case 'r':
      case 'jupyter notebook':
        return ProjectCategory.dataScience;
      case 'dockerfile':
      case 'shell':
        return ProjectCategory.devOps;
      default:
        return ProjectCategory.other;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub')),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: cs.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'GitHub Username',
                      prefixIcon: Icon(Icons.person_rounded),
                      hintText: 'e.g. torvalds',
                    ),
                    onSubmitted: (_) => _fetch(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _loading ? null : _fetch,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: !_hasFetched
                ? _EmptyPrompt()
                : _error != null
                    ? _ErrorState(message: _error!)
                    : _repos.isEmpty
                        ? const Center(child: Text('No public repos found.'))
                        : CustomScrollView(
                            slivers: [
                              // GitHub profile card
                              if (_ghProfile.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: _GHProfileCard(
                                    profile: _ghProfile,
                                    onOpenGitHub: () => _openUrl(
                                        _ghProfile['html_url'] ?? ''),
                                  ),
                                ),

                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 100),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _RepoCard(
                                        repo: _repos[i],
                                        onImport: () =>
                                            _importRepo(_repos[i]),
                                        onOpen: () =>
                                            _openUrl(_repos[i].url),
                                      ),
                                    ),
                                    childCount: _repos.length,
                                  ),
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

class _EmptyPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined,
              size: 72, color: cs.onSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Enter a GitHub username to fetch repos',
              style: GoogleFonts.inter(
                  color: cs.onSurfaceVariant, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: cs.error.withOpacity(0.7)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: cs.error, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GHProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onOpenGitHub;
  const _GHProfileCard(
      {required this.profile, required this.onOpenGitHub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                    profile['avatar_url'] ?? ''),
                backgroundColor: cs.primaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile['name'] ?? profile['login'] ?? '',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    if (profile['bio'] != null &&
                        profile['bio'].toString().isNotEmpty)
                      Text(
                        profile['bio'],
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatPill(
                            label: 'Repos',
                            value: '${profile['public_repos'] ?? 0}'),
                        const SizedBox(width: 8),
                        _StatPill(
                            label: 'Followers',
                            value: '${profile['followers'] ?? 0}'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new_rounded,
                    color: cs.primary, size: 20),
                onPressed: onOpenGitHub,
                tooltip: 'Open GitHub',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onPrimaryContainer),
      ),
    );
  }
}

class _RepoCard extends StatelessWidget {
  final GitHubRepo repo;
  final VoidCallback onImport;
  final VoidCallback onOpen;
  const _RepoCard(
      {required this.repo, required this.onImport, required this.onOpen});

  Color _langColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return const Color(0xFF3572A5);
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'javascript':
        return const Color(0xFFF1E05A);
      case 'typescript':
        return const Color(0xFF2B7489);
      case 'kotlin':
        return const Color(0xFFA97BFF);
      case 'swift':
        return const Color(0xFFFFAC45);
      case 'html':
        return const Color(0xFFE34C26);
      case 'css':
        return const Color(0xFF563D7C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final langColor = _langColor(repo.language);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_rounded,
                    color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repo.name,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (repo.isForked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('Fork',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurfaceVariant)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              repo.description,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Language dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: langColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(repo.language,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: cs.onSurfaceVariant)),
                const SizedBox(width: 12),
                Icon(Icons.star_rounded,
                    size: 14, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 3),
                Text('${repo.stars}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: cs.onSurfaceVariant)),
                const Spacer(),
                // Open button
                InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.open_in_new_rounded,
                        size: 16, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 8),
                // Import button
                FilledButton.tonal(
                  onPressed: onImport,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Import',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}