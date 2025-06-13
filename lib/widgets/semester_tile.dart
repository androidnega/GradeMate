import 'package:flutter/material.dart';
import '../models/semester_model.dart';
import '../utils/gpa_calculator.dart';
import '../screens/semester_detail_screen.dart';

class SemesterTile extends StatelessWidget {
  final SemesterModel semester;

  const SemesterTile({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    final gpa = semester.semesterGPA;
    final totalCredits = semester.totalCreditHours;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SemesterDetailScreen(semester: semester),
            ),
          );
        },
        title: Text(
          semester.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(semester.academicYear),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'GPA: ${GPACalculator.formatGPA(gpa)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text('Credits: $totalCredits'),
          ],
        ),
      ),
    );
  }
}
