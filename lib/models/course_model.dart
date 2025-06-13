import '../utils/gpa_calculator.dart';
import 'calculation_mode.dart';

class CourseModel {
  final String id;
  final String name;
  final int creditHours;
  final String grade;
  final double gradePoint;
  final double? rawScore; // New field for CWA calculation
  final CalculationMode mode;

  CourseModel({
    this.id = '', // Allow empty ID for new courses
    required this.name,
    required this.creditHours,
    required this.grade,
    required this.gradePoint,
    this.rawScore,
    this.mode = CalculationMode.gpa,
  });

  factory CourseModel.fromGrade({
    String id = '',
    required String name,
    required int creditHours,
    required String grade,
  }) {
    return CourseModel(
      id: id,
      name: name,
      creditHours: creditHours,
      grade: grade,
      gradePoint: GPACalculator.getGradePoint(grade),
      mode: CalculationMode.gpa,
    );
  }

  factory CourseModel.fromScore({
    String id = '',
    required String name,
    required int creditHours,
    required double score,
  }) {
    final grade = GPACalculator.percentageToGrade(score);
    return CourseModel(
      id: id,
      name: name,
      creditHours: creditHours,
      grade: grade,
      gradePoint: GPACalculator.getGradePoint(grade),
      rawScore: score,
      mode: CalculationMode.cwa,
    );
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      creditHours: map['credit_hours'] ?? 0,
      grade: map['grade'] ?? 'F',
      gradePoint: map['grade_point'] ?? 0.0,
      rawScore: map['raw_score'],
      mode: CalculationMode.values[map['mode'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credit_hours': creditHours,
      'grade': grade,
      'grade_point': gradePoint,
      'raw_score': rawScore,
      'mode': mode.index,
    };
  }
}
