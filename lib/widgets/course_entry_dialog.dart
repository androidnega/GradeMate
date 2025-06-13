import 'package:flutter/material.dart';
import '../models/calculation_mode.dart';
import '../models/course_model.dart';
import '../utils/gpa_calculator.dart';

class CourseEntryDialog extends StatefulWidget {
  final Function(CourseModel course) onSave;
  final CalculationMode mode;

  const CourseEntryDialog({
    super.key,
    required this.onSave,
    required this.mode,
  });

  @override
  State<CourseEntryDialog> createState() => _CourseEntryDialogState();
}

class _CourseEntryDialogState extends State<CourseEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  int _selectedCredit = 3;
  String _selectedGrade = 'A';

  final List<String> gradeOptions = GPACalculator.getAvailableGrades();
  double get _gradePoint => GPACalculator.getGradePoint(_selectedGrade);

  @override
  void dispose() {
    _courseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Course"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: "Course Name",
                  hintText: "e.g., Communication Skills 1",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedCredit,
                decoration: const InputDecoration(
                  labelText: "Credit Hours",
                  hintText: "Select credit hours",
                ),
                items:
                    List.generate(6, (i) => i + 1).map((hours) {
                      return DropdownMenuItem(
                        value: hours,
                        child: Text(
                          '$hours ${hours == 1 ? "Credit Hour" : "Credit Hours"}',
                        ),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCredit = val);
                },
              ),
              const SizedBox(height: 10),
              if (widget.mode == CalculationMode.gpa) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grade"),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: "View TTU Grade Scale",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("TTU Grade Scale"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("• A: 80–100% → 4.0"),
                                    Text("• B+: 75–79% → 3.5"),
                                    Text("• B: 70–74% → 3.0"),
                                    Text("• C+: 65–69% → 2.5"),
                                    Text("• C: 60–64% → 2.0"),
                                    Text("• D+: 55–59% → 1.5"),
                                    Text("• D: 50–54% → 1.0"),
                                    Text("• F: <50% → 0.0"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Close"),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(hintText: "Select grade"),
                  items:
                      gradeOptions.map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(
                            '$grade (${GPACalculator.getGradePoint(grade).toStringAsFixed(1)})',
                          ),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGrade = val);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Grade Point: ${_gradePoint.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ] else ...[
                TextFormField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Score",
                    hintText: "Enter score (0-100)",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a score';
                    }
                    final score = double.tryParse(value);
                    if (score == null || score < 0 || score > 100) {
                      return 'Enter a valid score between 0 and 100';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              if (widget.mode == CalculationMode.gpa) {
                final course = CourseModel.fromGrade(
                  name: _courseController.text.trim(),
                  creditHours: _selectedCredit,
                  grade: _selectedGrade,
                );
                widget.onSave(course);
              } else {
                final score = double.parse(_scoreController.text);
                final course = CourseModel.fromScore(
                  name: _courseController.text.trim(),
                  creditHours: _selectedCredit,
                  score: score,
                );
                widget.onSave(course);
              }
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
