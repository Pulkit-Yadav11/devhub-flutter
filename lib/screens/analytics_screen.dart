import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Project> projects;
  const AnalyticsScreen({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalStars = projects.fold(0, (s, p) => s + p.stars);
    final completed = projects
        .where((p) => p.status == DevelopmentStatus.completed)
        .length;
    final inProgress = projects
        .where((p) => p.status == DevelopmentStatus.inProgress)
        .length;

    // Category breakdown
    final catCounts = <ProjectCategory, int>{};
    for (final p in projects) {
      catCounts[p.category] = (catCounts[p.category] ?? 0) + 1;
    }
    final sortedCats = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Status breakdown
    final statusCounts = <DevelopmentStatus, int>{};
    for (final p in projects) {
      statusCounts[p.status] = (statusCounts[p.status] ?? 0) + 1;
    }

    // Top starred projects
    final topStarred = [...projects]
      ..sort((a, b) => b.stars.compareTo(a.stars));

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 72,
                      color: cs.onSurfaceVariant.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No data yet',
                      style: GoogleFonts.inter(
                          color: cs.onSurfaceVariant, fontSize: 16)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Summary cards row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Projects',
                        value: '${projects.length}',
                        icon: Icons.folder_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Stars',
                        value: '$totalStars',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Completed',
                        value: '$completed',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'In Progress',
                        value: '$inProgress',
                        icon: Icons.pending_rounded,
                        color: cs.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Completion rate
                if (projects.isNotEmpty) ...[
                  _SectionTitle('Completion Rate'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${((completed / projects.length) * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              Text(
                                '$completed / ${projects.length} projects',
                                style: GoogleFonts.inter(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: completed / projects.length,
                              minHeight: 10,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Category breakdown
                _SectionTitle('By Category'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: sortedCats.map((e) {
                        final pct = e.value / projects.length;
                        return _BarRow(
                          label: e.key.displayName,
                          count: e.value,
                          fraction: pct,
                          color: _catColor(e.key),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status breakdown
                _SectionTitle('By Status'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: statusCounts.entries.map((e) {
                        final pct = e.value / projects.length;
                        return _BarRow(
                          label: e.key.displayName,
                          count: e.value,
                          fraction: pct,
                          color: _statusColor(e.key),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Top starred
                if (topStarred.isNotEmpty) ...[
                  _SectionTitle('Top Starred Projects'),
                  const SizedBox(height: 12),
                  ...topStarred.take(3).map((p) => _TopProjectRow(project: p)),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Color _catColor(ProjectCategory c) {
    switch (c) {
      case ProjectCategory.aiMl:
        return const Color(0xFF6C63FF);
      case ProjectCategory.webDev:
        return const Color(0xFF3B82F6);
      case ProjectCategory.mobileApp:
        return const Color(0xFF10B981);
      case ProjectCategory.dataScience:
        return const Color(0xFFF59E0B);
      case ProjectCategory.devOps:
        return const Color(0xFFEF4444);
      case ProjectCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusColor(DevelopmentStatus s) {
    switch (s) {
      case DevelopmentStatus.inProgress:
        return const Color(0xFF3B82F6);
      case DevelopmentStatus.completed:
        return const Color(0xFF10B981);
      case DevelopmentStatus.maintenance:
        return const Color(0xFFF59E0B);
      case DevelopmentStatus.archived:
        return const Color(0xFF6B7280);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final double fraction;
  final Color color;

  const _BarRow(
      {required this.label,
      required this.count,
      required this.fraction,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text('$count',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProjectRow extends StatelessWidget {
  final Project project;
  const _TopProjectRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.star_rounded,
              color: const Color(0xFFF59E0B), size: 20),
        ),
        title: Text(project.title,
            style:
                GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(project.category.displayName,
            style: GoogleFonts.inter(fontSize: 12)),
        trailing: Text(
          '${project.stars} ★',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF59E0B),
              fontSize: 14),
        ),
      ),
    );
  }
}
