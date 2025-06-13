import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/calculation_mode.dart';

class AddCourseDialog extends StatefulWidget {
  final CourseModel? initialCourse;
  final CalculationMode mode;

  const AddCourseDialog({super.key, this.initialCourse, required this.mode});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _creditHoursController;
  late final TextEditingController _scoreController;
  String _selectedGrade = 'A';
  final List<String> _grades = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialCourse?.name ?? '',
    );
    _creditHoursController = TextEditingController(
      text: widget.initialCourse?.creditHours.toString() ?? '',
    );
    _scoreController = TextEditingController(
      text: widget.initialCourse?.rawScore?.toString() ?? '',
    );
    if (widget.initialCourse != null) {
      _selectedGrade = widget.initialCourse!.grade;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditHoursController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        widget.initialCourse == null ? 'Add Course' : 'Edit Course',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                hintText: 'e.g., Mathematics',
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creditHoursController,
              decoration: const InputDecoration(
                labelText: 'Credit Hours',
                hintText: 'e.g., 3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (widget.mode == CalculationMode.cwa)
              TextField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score (%)',
                  hintText: 'e.g., 85',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade'),
                items:
                    _grades
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGrade = value);
                  }
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final creditHoursText = _creditHoursController.text.trim();
            final scoreText = _scoreController.text.trim();

            if (name.isEmpty || creditHoursText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all required fields'),
                ),
              );
              return;
            }

            final creditHours = int.tryParse(creditHoursText);
            if (creditHours == null || creditHours <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid number of credit hours'),
                ),
              );
              return;
            }

            CourseModel course;
            if (widget.mode == CalculationMode.cwa) {
              final score = double.tryParse(scoreText);
              if (score == null || score < 0 || score > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid score (0-100)'),
                  ),
                );
                return;
              }
              course = CourseModel.fromScore(
                id: widget.initialCourse?.id ?? '',
                name: name,
                creditHours: creditHours,
                score: score,
              );
            } else {
              course = CourseModel.fromGrade(
                id: widget.initialCourse?.id ?? '',
                name: name,
                creditHours: creditHours,
                grade: _selectedGrade,
              );
            }

            Navigator.pop(context, course);
          },
          child: Text(widget.initialCourse == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
