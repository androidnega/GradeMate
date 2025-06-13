import 'package:flutter/material.dart';
import '../models/calculation_mode.dart';
import '../models/course_model.dart';
import '../utils/gpa_calculator.dart';

class AddCourseDialog extends StatefulWidget {
  final CalculationMode mode;

  const AddCourseDialog({super.key, this.mode = CalculationMode.gpa});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  String _selectedGrade = 'A';
  int _selectedCredit = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g., Communication Skills 1',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCredit,
                decoration: const InputDecoration(
                  labelText: 'Credit Hours',
                  hintText: 'Select credit hours',
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
              const SizedBox(height: 16),
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
                      GPACalculator.getAvailableGrades()
                          .map(
                            (grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(
                                '$grade (${GPACalculator.getGradePoint(grade)})',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGrade = value);
                    }
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Score (%)',
                    hintText: 'Enter score between 0-100',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text.trim();

              CourseModel course;
              if (widget.mode == CalculationMode.gpa) {
                course = CourseModel.fromGrade(
                  name: name,
                  creditHours: _selectedCredit,
                  grade: _selectedGrade,
                );
              } else {
                final score = double.parse(_scoreController.text);
                course = CourseModel.fromScore(
                  name: name,
                  creditHours: _selectedCredit,
                  score: score,
                );
              }

              Navigator.pop(context, course);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
