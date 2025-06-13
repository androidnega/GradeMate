import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/course_model.dart';
import '../utils/classification_utils.dart';
import '../models/degree_level.dart';
import 'auth/login_screen.dart';
import 'about_screen.dart';
import '../widgets/add_course_dialog.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/gpa_calculator.dart';
import '../models/calculation_mode.dart';

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

  IconData _getAchievementIcon(double gpa) {
    if (gpa >= 3.6) return Icons.emoji_events_rounded;
    if (gpa >= 3.0) return Icons.star_rounded;
    if (gpa >= 2.5) return Icons.thumb_up_rounded;
    return Icons.school_rounded;
  }

  String _getAchievementText(double gpa) {
    if (gpa >= 3.6) return 'Outstanding';
    if (gpa >= 3.0) return 'Excellent';
    if (gpa >= 2.5) return 'Good Work';
    return 'Keep Going';
  }

  Color _getAchievementColor(double gpa) {
    if (gpa >= 3.6) return Colors.amber;
    if (gpa >= 3.0) return Colors.lightGreenAccent;
    if (gpa >= 2.5) return Colors.lightBlue;
    return Colors.grey.shade400;
  }

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

  IconData _getAchievementIcon(double gpa) {
    if (gpa >= 3.6) return Icons.emoji_events_rounded;
    if (gpa >= 3.0) return Icons.star_rounded;
    if (gpa >= 2.5) return Icons.thumb_up_rounded;
    return Icons.school_rounded;
  }

  String _getAchievementText(double gpa) {
    if (gpa >= 3.6) return 'Outstanding';
    if (gpa >= 3.0) return 'Excellent';
    if (gpa >= 2.5) return 'Good Work';
    return 'Keep Going';
  }

  Color _getAchievementColor(double gpa) {
    if (gpa >= 3.6) return Colors.amber;
    if (gpa >= 3.0) return Colors.lightGreenAccent;
    if (gpa >= 2.5) return Colors.lightBlue;
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GradeMate Calculator"),
        actions: [
          // Info button for grade scale
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "View grade scale",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    _calculationMode == CalculationMode.gpa
                        ? 'About GPA Calculation'
                        : 'About CWA Calculation',
                  ),
                  content: Text(
                    _calculationMode == CalculationMode.gpa
                        ? 'This calculator uses a 4.0 scale.\n\n'
                            'A: 4.0\nB+: 3.5\nB: 3.0\n'
                            'C+: 2.5\nC: 2.0\nD+: 1.5\n'
                            'D: 1.0\nF: 0.0'
                        : 'This calculator uses TTU\'s CWA system.\n\n'
                            '≥80%: Distinction\n'
                            '70-79%: Very Good\n'
                            '60-69%: Credit\n'
                            '50-59%: Pass\n'
                            '<50%: Fail',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          // About button
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "About developer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(_calculationMode == CalculationMode.gpa ? 'GPA Calculator' : 'CWA Calculator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: "View grade scale",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        _calculationMode == CalculationMode.gpa
                            ? 'About GPA Calculation'
                            : 'About CWA Calculation',
                      ),
                      content: Text(
                        _calculationMode == CalculationMode.gpa
                            ? 'This calculator uses a 4.0 scale.\n\n'
                                'A: 4.0\nB+: 3.5\nB: 3.0\n'
                                'C+: 2.5\nC: 2.0\nD+: 1.5\n'
                                'D: 1.0\nF: 0.0'
                            : 'This calculator uses TTU\'s CWA system.\n\n'
                                '≥80%: Distinction\n'
                                '70-79%: Very Good\n'
                                '60-69%: Credit\n'
                                '50-59%: Pass\n'
                                '<50%: Fail',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: "About developer",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
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
                Column(                      children: [
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
                                      color: Colors.white.withOpacity(0.2),
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
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getAchievementIcon(_gpa),
                                    color: _getAchievementColor(_gpa),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getAchievementText(_gpa),
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
              ],
            ),
          ),          if (_courses.isEmpty)
            SliverFillRemaining(
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
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = _courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
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
                                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
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
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn().slideX(begin: 0.2);
                  },
                  childCount: _courses.length,
                ),
              ),
            ),
          if (widget.isGuest && _courses.isNotEmpty)
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Want to save your progress?",
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text("Sign in"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
      ),
    );
  }
}
