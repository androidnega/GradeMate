import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/course_model.dart';

class CourseTile extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAnimated;

  const CourseTile({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget tile = Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Credit Hours: ${course.creditHours}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Edit Course',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getGradeColor(course.grade, isDark, colorScheme),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Grade: ${course.grade} | Score: ${course.score}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isAnimated) {
      tile = tile
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
    }

    return tile;
  }

  Color _getGradeColor(String grade, bool isDark, ColorScheme colorScheme) {
    if (isDark) {
      switch (grade.toUpperCase()) {
        case 'A':
          return Colors.green.shade800;
        case 'B+':
        case 'B':
          return Colors.blue.shade800;
        case 'C+':
        case 'C':
          return Colors.orange.shade800;
        case 'D+':
        case 'D':
          return Colors.red.shade800;
        default:
          return Colors.grey.shade800;
      }
    } else {
      switch (grade.toUpperCase()) {
        case 'A':
          return Colors.green.shade100;
        case 'B+':
        case 'B':
          return Colors.blue.shade100;
        case 'C+':
        case 'C':
          return Colors.orange.shade100;
        case 'D+':
        case 'D':
          return Colors.red.shade100;
        default:
          return Colors.grey.shade200;
      }
    }
  }
}
