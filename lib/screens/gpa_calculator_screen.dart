import 'package:flutter/material.dart';
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
                Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          _calculationMode == CalculationMode.gpa
                              ? 'Current GPA'
                              : 'Current CWA',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _calculationMode == CalculationMode.gpa
                              ? GPACalculator.formatGPA(_gpa)
                              : GPACalculator.formatCWA(_cwa),
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Standing: ${_calculationMode == CalculationMode.gpa ? ClassificationUtils.getClassification(_degreeLevel, _gpa) : GPACalculator.getCWAClassification(_cwa)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _courses.isEmpty
                    ? Center(
                      child: Text(
                        'Tap + to add your courses',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              title: Text(course.name),
                              subtitle: Text(
                                _calculationMode == CalculationMode.gpa
                                    ? '${course.creditHours} credits • Grade: ${course.grade}'
                                    : '${course.creditHours} credits • Score: ${course.rawScore?.toStringAsFixed(1) ?? "-"}%',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeCourse(index),
                              ),
                            ),
                          ),
                        );
                      },
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
