import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import 'detail_screen.dart';

class FeedScreen extends StatefulWidget {
  final List<Project> projects;
  final Function(String) onToggleStar;
  final Function(String) onDelete;

  const FeedScreen({
    super.key,
    required this.projects,
    required this.onToggleStar,
    required this.onDelete,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ProjectCategory? _selectedCat;
  DevelopmentStatus? _selectedStatus;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Project> get _filtered {
    return widget.projects.where((p) {
      final q = _query.toLowerCase();
      final matchQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.techStack.toLowerCase().contains(q) ||
          p.author.toLowerCase().contains(q);
      final matchCat = _selectedCat == null || p.category == _selectedCat;
      final matchStatus =
          _selectedStatus == null || p.status == _selectedStatus;
      return matchQuery && matchCat && matchStatus;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _selectedCat = null;
      _selectedStatus = null;
      _searchCtrl.clear();
    });
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _selectedCat != null || _selectedStatus != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Row(
              children: [
                Icon(Icons.hub_rounded, color: cs.primary, size: 22),
                const SizedBox(width: 8),
                Text('DevHub',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              if (_hasFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search projects, tech, author…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() {
                                      _query = '';
                                      _searchCtrl.clear();
                                    }),
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    // Category chips
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _selectedCat == null,
                            onTap: () =>
                                setState(() => _selectedCat = null),
                          ),
                          ...ProjectCategory.values.map((c) => _FilterChip(
                                label: c.displayName,
                                selected: _selectedCat == c,
                                onTap: () => setState(() =>
                                    _selectedCat = _selectedCat == c ? null : c),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? _EmptyState(hasFilters: _hasFilters, onClear: _clearFilters)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final project = filtered[i];
                  return ProjectCard(
                    project: project,
                    onToggleStar: () => widget.onToggleStar(project.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            project: project,
                            onToggleStar: () =>
                                widget.onToggleStar(project.id),
                            onDelete: () {
                              widget.onDelete(project.id);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;
  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.folder_open_rounded,
            size: 72,
            color: cs.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No projects match your filters' : 'No projects yet',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Tap + New Project to add your first one',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onClear,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
