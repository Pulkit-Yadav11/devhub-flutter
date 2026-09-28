import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onToggleStar,
  });

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = _catColor(project.category);
    final statusColor = _statusColor(project.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored top strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: category + status badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.category.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.status.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    project.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description preview
                  Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tech chips (first 3)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: project.techStack
                        .split(',')
                        .take(3)
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                t.trim(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Bottom: author + star
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          project.author.isNotEmpty
                              ? project.author[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          project.author,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Star button
                      GestureDetector(
                        onTap: onToggleStar,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              project.isStarred
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: project.isStarred
                                  ? const Color(0xFFF59E0B)
                                  : cs.onSurfaceVariant,
                              size: 18,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${project.stars}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: project.isStarred
                                    ? const Color(0xFFF59E0B)
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
