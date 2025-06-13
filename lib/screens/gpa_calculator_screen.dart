import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/course_model.dart';
import '../utils/classification_utils.dart';
import '../models/degree_level.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/gpa_calculator.dart';
import '../models/calculation_mode.dart';
import '../utils/achievement_utils.dart';
import '../widgets/guest_warning_dialog.dart';
import '../screens/welcome_screen.dart';
import '../dialogs/add_course_dialog.dart';

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
  bool _hasShownGuestWarning = false;

  @override
  void initState() {
    super.initState();
    if (widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGuestWarningIfNeeded();
      });
    }
  }

  Future<void> _showGuestWarningIfNeeded() async {
    if (!widget.isGuest || _hasShownGuestWarning) return;

    final shouldCreateAccount = await showDialog<bool>(
      context: context,
      builder: (_) => const GuestWarningDialog(),
    );

    setState(() => _hasShownGuestWarning = true);

    if (shouldCreateAccount == true) {
      if (!mounted) return; // Navigate to sign up screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
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

  Widget _buildCourseItem(CourseModel course, int index) {
    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withAlpha(128),
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
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
                            Text(
                              '${course.creditHours} credit hours',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withAlpha(128),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _calculationMode == CalculationMode.gpa
                          ? 'Grade: ${course.grade}'
                          : 'Score: ${course.rawScore?.toStringAsFixed(1) ?? "-"}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _calculationMode == CalculationMode.gpa
              ? 'GPA Calculator'
              : 'CWA Calculator',
        ),
        actions: [
          if (_courses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Clear All Courses'),
                        content: const Text(
                          'Are you sure you want to clear all courses? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _courses.clear();
                                _updateResults();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                );
              },
              tooltip: 'Clear All Courses',
            ),
        ],
      ),
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
                    // Mode Toggle & Degree Level Selection
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
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<DegreeLevel>(
                        value: _degreeLevel,
                        isExpanded: true,
                        underline: const SizedBox(),
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
                                    child: Text(
                                      level.toString().split('.').last,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Result Display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          _calculationMode ==
                                                  CalculationMode.gpa
                                              ? GPACalculator.formatGPA(_gpa)
                                              : GPACalculator.formatCWA(_cwa),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.displaySmall?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _calculationMode ==
                                                  CalculationMode.gpa
                                              ? 'GPA'
                                              : 'CWA',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color: colorScheme.onPrimary
                                                .withAlpha(200),
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
                                        color: colorScheme.onPrimary.withAlpha(
                                          40,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _calculationMode == CalculationMode.gpa
                                            ? ClassificationUtils.getClassification(
                                              _degreeLevel,
                                              _gpa,
                                            )
                                            : GPACalculator.getCWAClassification(
                                              _cwa,
                                            ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Achievement Icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      AchievementUtils.getAchievementIcon(_gpa),
                                      color: colorScheme.onPrimary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AchievementUtils.getAchievementText(_gpa),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
