import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';

class DetailScreen extends StatelessWidget {
  final Project project;
  final VoidCallback onToggleStar;
  final VoidCallback onDelete;

  const DetailScreen({
    super.key,
    required this.project,
    required this.onToggleStar,
    required this.onDelete,
  });

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

  Future<void> _openGitHub(BuildContext context) async {
    final url = Uri.parse(project.githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
            'Are you sure you want to delete "${project.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final techItems = project.techStack
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final statusColor = _statusColor(project.status);
    final catColor = _catColor(project.category);
    final formattedDate =
        DateFormat('MMM d, yyyy · h:mm a').format(project.timestamp);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      catColor.withOpacity(0.8),
                      cs.primary.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(Icons.hub_rounded,
                          size: 180,
                          color: Colors.white.withOpacity(0.07)),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              project.category.displayName,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  project.isStarred
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: project.isStarred
                      ? const Color(0xFFF59E0B)
                      : Colors.white,
                ),
                onPressed: onToggleStar,
                tooltip: project.isStarred ? 'Unstar' : 'Star',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _confirmDelete(context);
                  if (v == 'copy') {
                    Clipboard.setData(
                        ClipboardData(text: project.techStack));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tech stack copied!')),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'copy',
                      child: ListTile(
                          leading: Icon(Icons.copy_rounded),
                          title: Text('Copy Tech Stack'),
                          contentPadding: EdgeInsets.zero)),
                  const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                          leading: Icon(Icons.delete_outline_rounded,
                              color: Colors.red),
                          title: Text('Delete Project',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero)),
                ],
              ),
            ],
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  Row(
                    children: [
                      _MetaBadge(
                        label: project.status.displayName,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      _MetaBadge(
                        label: '${project.stars} ★',
                        color: const Color(0xFFF59E0B),
                      ),
                      const Spacer(),
                      Text(
                        project.id,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Author & Date
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: cs.primaryContainer,
                            child: Text(
                              project.author.isNotEmpty
                                  ? project.author[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimaryContainer,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(project.author,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(
                                'Lead Developer',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formattedDate.split('·')[0].trim(),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant)),
                              Text(formattedDate.split('·')[1].trim(),
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant
                                          .withOpacity(0.6))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('About',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.65,
                        color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  // Tech stack
                  Text('Tech Stack',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: techItems
                        .map((t) => _TechChip(label: t))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // GitHub button
                  if (project.githubUrl.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openGitHub(context),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('View on GitHub'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.onPrimaryContainer,
        ),
      ),
    );
  }
}
