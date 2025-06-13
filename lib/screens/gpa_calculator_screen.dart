import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/course_model.dart';
import '../utils/classification_utils.dart';
import '../models/degree_level.dart';
import '../widgets/add_course_dialog.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/gpa_calculator.dart';
import '../models/calculation_mode.dart';
import '../utils/achievement_utils.dart';

class GpaCalculatorScreen extends StatefulWidget {
  final bool isGuest;

  const GpaCalculatorScreen({super.key, required this.isGuest});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<CourseModel> _courses = [];
  double _gpa = 0.0;
  double _cwa = 0.0;
  DegreeLevel _degreeLevel = DegreeLevel.bTech;
  CalculationMode _calculationMode = CalculationMode.gpa;

  Future<void> _saveGpaResult() async {
    final user = AuthService.currentUser;
    if (user != null) {
      await FirestoreService.saveGpaResult(
        userId: user.uid,
        gpa:
            _calculationMode == CalculationMode.gpa
                ? _gpa
                : _cwa / 25, // Convert CWA to GPA scale
        cgpa: _calculationMode == CalculationMode.gpa ? _gpa : _cwa / 25,
        classification:
            _calculationMode == CalculationMode.gpa
                ? ClassificationUtils.getClassification(_degreeLevel, _gpa)
                : GPACalculator.getCWAClassification(_cwa),
        semesterLabel: "Current Semester",
        degreeLevel: _degreeLevel.toString().split('.').last,
      );
    }
  }

  void _updateResults() {
    if (_courses.isEmpty) {
      setState(() {
        _gpa = 0.0;
        _cwa = 0.0;
      });
      return;
    }

    if (_calculationMode == CalculationMode.gpa) {
      setState(() => _gpa = GPACalculator.calculateSemesterGPA(_courses));
    } else {
      setState(() => _cwa = GPACalculator.calculateCWA(_courses));
    }

    if (!widget.isGuest) {
      _saveGpaResult();
    }
  }

  Future<void> _addCourse() async {
    final course = await showDialog<CourseModel>(
      context: context,
      builder: (_) => AddCourseDialog(mode: _calculationMode),
    );

    if (course != null) {
      setState(() => _courses.add(course));
      _updateResults();
    }
  }

  void _removeCourse(int index) {
    setState(() => _courses.removeAt(index));
    _updateResults();
  }

  Widget _buildCourseItem(CourseModel course, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _removeCourse(index),
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${course.creditHours} credit hours',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _removeCourse(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _calculationMode == CalculationMode.gpa
                      ? 'Grade: ${course.grade}'
                      : 'Score: ${course.rawScore?.toStringAsFixed(1) ?? "-"}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],          ),
        ),
      ).animate().fadeIn().slideX(begin: 0.2, duration: 400.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode Toggle
                    SegmentedButton<CalculationMode>(
                      selected: {_calculationMode},
                      onSelectionChanged: (Set<CalculationMode> selected) {
                        setState(() {
                          _calculationMode = selected.first;
                          _courses.clear(); // Clear courses when switching modes
                          _updateResults();
                        });
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
                    const SizedBox(height: 12),
                    DropdownButton<DegreeLevel>(
                      value: _degreeLevel,
                      onChanged: (DegreeLevel? newValue) {
                        if (newValue != null) {
                          setState(() => _degreeLevel = newValue);
                        }
                      },
                      items:
                          DegreeLevel.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.toString().split('.').last),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        // Mode Toggle
                        SegmentedButton<CalculationMode>(
                          selected: {_calculationMode},
                          onSelectionChanged: (Set<CalculationMode> selected) {
                            setState(() {
                              _calculationMode = selected.first;
                              _courses.clear();
                              _updateResults();
                            });
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
                        ).animate().fadeIn().slideY(begin: -0.2),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _calculationMode == CalculationMode.gpa
                                            ? GPACalculator.formatGPA(_gpa)
                                            : GPACalculator.formatCWA(_cwa),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _calculationMode == CalculationMode.gpa ? 'GPA' : 'CWA',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _calculationMode == CalculationMode.gpa
                                          ? ClassificationUtils.getClassification(_degreeLevel, _gpa)
                                          : GPACalculator.getCWAClassification(_cwa),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    AchievementUtils.getAchievementIcon(_gpa),
                                    color: AchievementUtils.getAchievementColor(_gpa),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AchievementUtils.getAchievementText(_gpa),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_courses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ).animate().scale(),
                    const SizedBox(height: 16),
                    Text(
                      'No courses yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first course to calculate ${_calculationMode == CalculationMode.gpa ? 'GPA' : 'CWA'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),
          if (_courses.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCourseItem(_courses[index], index),
                childCount: _courses.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Course'),
      ),
    );
  }
}
