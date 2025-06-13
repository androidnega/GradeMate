import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class GuestCourseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int creditHours;

  @HiveField(3)
  final String grade;

  @HiveField(4)
  final double gradePoint;

  GuestCourseModel({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.grade,
    required this.gradePoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creditHours': creditHours,
      'grade': grade,
      'gradePoint': gradePoint,
    };
  }

  factory GuestCourseModel.fromMap(Map<String, dynamic> map) {
    return GuestCourseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      creditHours: map['creditHours'] as int,
      grade: map['grade'] as String,
      gradePoint: map['gradePoint'] as double,
    );
  }
}
