import 'course_model.dart';

class SemesterModel {
  final String id;
  final String title;
  final String academicYear;
  final List<CourseModel> courses;
  final DateTime createdAt;

  SemesterModel({
    required this.id,
    required this.title,
    required this.academicYear,
    this.courses = const [],
    required this.createdAt,
  });

  factory SemesterModel.fromMap(Map<String, dynamic> map, String id) {
    return SemesterModel(
      id: id,
      title: map['title'] ?? '',
      academicYear: map['academic_year'] ?? '',
      courses: [], // Courses will be loaded separately
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at']?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'academic_year': academicYear,
      'created_at': createdAt,
    };
  }

  double get semesterGPA {
    if (courses.isEmpty) return 0.0;

    double totalGradePoints = 0;
    int totalCreditHours = 0;

    for (final course in courses) {
      totalGradePoints += course.gradePoint * course.creditHours;
      totalCreditHours += course.creditHours;
    }

    return totalCreditHours > 0 ? totalGradePoints / totalCreditHours : 0.0;
  }

  int get totalCreditHours {
    return courses.fold(0, (sum, course) => sum + course.creditHours);
  }

  SemesterModel copyWith({
    String? id,
    String? title,
    String? academicYear,
    List<CourseModel>? courses,
    DateTime? createdAt,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      academicYear: academicYear ?? this.academicYear,
      courses: courses ?? this.courses,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
