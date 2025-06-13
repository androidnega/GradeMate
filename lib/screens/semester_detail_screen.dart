import 'package:flutter/material.dart';
import '../models/calculation_mode.dart';
import '../models/course_model.dart';
import '../models/semester_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/gpa_calculator.dart';
import '../widgets/course_entry_dialog.dart';

class SemesterDetailScreen extends StatefulWidget {
  final SemesterModel semester;

  const SemesterDetailScreen({super.key, required this.semester});

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  late Stream<SemesterModel> _semesterStream;
  final _scoreController = TextEditingController();
  CalculationMode _calculationMode = CalculationMode.gpa;

  @override
  void initState() {
    super.initState();
    _semesterStream = FirestoreService.semesterStream(
      AuthService.currentUser!.uid,
      widget.semester.id,
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _showAddCourseDialog() {
    showDialog<CourseModel>(
      context: context,
      builder:
          (_) => CourseEntryDialog(
            mode: _calculationMode,
            onSave: (course) async {
              await FirestoreService.addCourse(
                AuthService.currentUser!.uid,
                widget.semester.id,
                course,
              );
            },
          ),
    );
  }

  Future<void> _deleteCourse(CourseModel course) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: const Text('Are you sure you want to delete this course?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirestoreService.deleteCourse(
        AuthService.currentUser!.uid,
        widget.semester.id,
        course.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semester.title),
        actions: [
          // Mode Toggle
          SegmentedButton<CalculationMode>(
            selected: {_calculationMode},
            onSelectionChanged: (Set<CalculationMode> selected) {
              setState(() => _calculationMode = selected.first);
            },
            segments: const [
              ButtonSegment<CalculationMode>(
                value: CalculationMode.gpa,
                label: Text('GPA'),
              ),
              ButtonSegment<CalculationMode>(
                value: CalculationMode.cwa,
                label: Text('CWA'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<SemesterModel>(
        stream: _semesterStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final semester = snapshot.data;
          if (semester == null) {
            return const Center(child: Text('Semester not found'));
          }

          if (semester.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first course',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withAlpha(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          _calculationMode == CalculationMode.gpa
                              ? 'Semester GPA'
                              : 'Semester CWA',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculationMode == CalculationMode.gpa
                              ? GPACalculator.formatGPA(semester.semesterGPA)
                              : GPACalculator.formatCWA(
                                GPACalculator.calculateCWA(semester.courses),
                              ),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Total Credits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          semester.totalCreditHours.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: semester.courses.length,
                  itemBuilder: (context, index) {
                    final course = semester.courses[index];
                    return Card(
                      child: ListTile(
                        title: Text(course.name),
                        subtitle: Text(
                          course.mode == CalculationMode.gpa
                              ? '${course.creditHours} credits • Grade: ${course.grade}'
                              : '${course.creditHours} credits • Score: ${course.rawScore?.toStringAsFixed(1) ?? "-"}%',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course.mode == CalculationMode.gpa
                                    ? course.grade
                                    : '${course.rawScore?.toStringAsFixed(1) ?? "-"}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteCourse(course),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
