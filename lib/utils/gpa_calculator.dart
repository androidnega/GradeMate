import '../models/course_model.dart';
import '../models/calculation_mode.dart';

class GPACalculator {
  static const Map<String, double> gradePoints = {
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D+': 1.5,
    'D': 1.0,
    'F': 0.0,
  };

  /// Calculate GPA for a single semester
  static double calculateSemesterGPA(List<CourseModel> courses) {
    if (courses.isEmpty) return 0.0;

    double totalGradePoints = 0.0;
    double totalCreditHours = 0.0;

    for (final course in courses) {
      totalGradePoints += course.gradePoint * course.creditHours;
      totalCreditHours += course.creditHours;
    }

    return totalCreditHours > 0 ? totalGradePoints / totalCreditHours : 0.0;
  }

  /// Calculate CWA (Cumulative Weighted Average) for a set of courses
  static double calculateCWA(List<CourseModel> courses) {
    if (courses.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalCredits = 0.0;

    for (final course in courses) {
      if (course.mode == CalculationMode.cwa) {
        totalWeightedScore += course.rawScore! * course.creditHours;
      } else {
        totalWeightedScore +=
            _gradeToPercentage(course.grade) * course.creditHours;
      }
      totalCredits += course.creditHours;
    }

    return totalCredits > 0 ? totalWeightedScore / totalCredits : 0.0;
  }

  /// Convert percentage score to letter grade
  static String percentageToGrade(double percentage) {
    if (percentage >= 80) return 'A';
    if (percentage >= 75) return 'B+';
    if (percentage >= 70) return 'B';
    if (percentage >= 65) return 'C+';
    if (percentage >= 60) return 'C';
    if (percentage >= 55) return 'D+';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  /// Convert letter grade to percentage score (using TTU midpoint values)
  static double _gradeToPercentage(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 90.0; // midpoint of 80-100
      case 'B+':
        return 77.5; // midpoint of 75-79.99
      case 'B':
        return 72.5; // midpoint of 70-74.99
      case 'C+':
        return 67.5; // midpoint of 65-69.99
      case 'C':
        return 62.5; // midpoint of 60-64.99
      case 'D+':
        return 57.5; // midpoint of 55-59.99
      case 'D':
        return 52.5; // midpoint of 50-54.99
      default:
        return 25.0; // midpoint of 0-49.99
    }
  }

  /// Get grade point value for a letter grade
  static double getGradePoint(String grade) {
    return gradePoints[grade.toUpperCase()] ?? 0.0;
  }

  /// Get all available grades
  static List<String> getAvailableGrades() {
    return gradePoints.keys.toList();
  }

  /// Convert GPA to letter grade (approximate)
  static String gpaToLetterGrade(double gpa) {
    if (gpa >= 4.0) return 'A';
    if (gpa >= 3.7) return 'A-';
    if (gpa >= 3.3) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.7) return 'B-';
    if (gpa >= 2.3) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.7) return 'C-';
    if (gpa >= 1.3) return 'D+';
    if (gpa >= 1.0) return 'D';
    if (gpa >= 0.7) return 'D-';
    return 'F';
  }

  /// Format GPA to display with 2 decimal places
  static String formatGPA(double gpa) {
    return gpa.toStringAsFixed(2);
  }

  /// Format CWA to display with 2 decimal places and percentage symbol
  static String formatCWA(double cwa) {
    return '${cwa.toStringAsFixed(2)}%';
  }

  /// Get CWA classification based on TTU standards
  static String getCWAClassification(double cwa) {
    if (cwa >= 80) return 'Distinction';
    if (cwa >= 70) return 'Very Good';
    if (cwa >= 60) return 'Credit';
    if (cwa >= 50) return 'Pass';
    return 'Fail';
  }

  /// Calculate what GPA is needed in remaining credit hours to achieve target CGPA
  static double requiredGPAForTarget({
    required double currentCGPA,
    required int currentCreditHours,
    required int remainingCreditHours,
    required double targetCGPA,
  }) {
    if (remainingCreditHours <= 0) return currentCGPA;

    final totalCreditHours = currentCreditHours + remainingCreditHours;
    final currentGradePoints = currentCGPA * currentCreditHours;
    final targetGradePoints = targetCGPA * totalCreditHours;
    final neededGradePoints = targetGradePoints - currentGradePoints;

    return neededGradePoints / remainingCreditHours;
  }
}

// Helper classes for calculations
class CourseData {
  final String name;
  final int creditHours;
  final double gradePoint;

  CourseData({
    required this.name,
    required this.creditHours,
    required this.gradePoint,
  });
}

class SemesterData {
  final String title;
  final List<CourseData> courses;

  SemesterData({required this.title, required this.courses});
}
