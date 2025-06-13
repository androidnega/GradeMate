import 'package:flutter/material.dart';
import '../models/semester_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/gpa_calculator.dart';

class CGPAScreen extends StatelessWidget {
  const CGPAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator')),
      body: StreamBuilder<List<SemesterModel>>(
        stream: FirestoreService.semestersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final semesters = snapshot.data ?? [];
          if (semesters.isEmpty) {
            return const Center(
              child: Text('No semesters found. Add some semesters first!'),
            );
          }
          final cgpa =
              semesters.isEmpty
                  ? 0.0
                  : semesters
                          .expand((s) => s.courses)
                          .fold<double>(
                            0.0,
                            (sum, course) =>
                                sum + (course.gradePoint * course.creditHours),
                          ) /
                      semesters
                          .expand((s) => s.courses)
                          .fold<double>(
                            0.0,
                            (sum, course) => sum + course.creditHours,
                          );
          final totalCredits = semesters.fold<int>(
            0,
            (sum, semester) => sum + semester.totalCreditHours,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Cumulative GPA',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          GPACalculator.formatGPA(cgpa),
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Letter Grade: ${GPACalculator.gpaToLetterGrade(cgpa)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Credits: $totalCredits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Semester Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...semesters.map((semester) {
                  final semesterGPA = semester.semesterGPA;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(semester.title),
                      subtitle: Text(semester.academicYear),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GPA: ${GPACalculator.formatGPA(semesterGPA)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Credits: ${semester.totalCreditHours}'),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
