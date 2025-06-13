import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';
import '../models/semester_model.dart';
import '../models/guest_course_model_adapter.dart';

class LocalStorageService {
  static const String _semestersBox = 'semesters';
  static const String _coursesBox = 'courses';
  static Box<dynamic>? _semestersBoxInstance;
  static Box<dynamic>? _coursesBoxInstance;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    _semestersBoxInstance = await Hive.openBox(_semestersBox);
    _coursesBoxInstance = await Hive.openBox(_coursesBox);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GuestCourseModelAdapter());
      }
    }
  }

  static Future<void> saveSemester(SemesterModel semester) async {
    final box = _semestersBoxInstance;
    if (box == null) throw Exception('Storage not initialized');

    await box.put(semester.id, semester.toMap());

    // Save courses separately
    await Future.wait(
      semester.courses.map((course) => saveCourse(semester.id, course)),
    );
  }

  static Future<void> saveCourse(String semesterId, CourseModel course) async {
    final box = _coursesBoxInstance;
    if (box == null) throw Exception('Storage not initialized');

    final key = '${semesterId}_${course.id}';
    await box.put(key, course.toMap());
  }

  static Future<List<SemesterModel>> getSemesters() async {
    final box = _semestersBoxInstance;
    if (box == null) throw Exception('Storage not initialized');

    final semesters = <SemesterModel>[];
    for (final key in box.keys) {
      final semesterMap = box.get(key) as Map;
      final courses = await getCourses(key.toString());
      semesters.add(
        SemesterModel.fromMap(
          Map<String, dynamic>.from(semesterMap),
          key.toString(),
        ).copyWith(courses: courses),
      );
    }

    return semesters;
  }

  static Future<List<CourseModel>> getCourses(String semesterId) async {
    final box = _coursesBoxInstance;
    if (box == null) throw Exception('Storage not initialized');

    final courses = <CourseModel>[];
    for (final key in box.keys) {
      if (key.toString().startsWith('${semesterId}_')) {
        final courseMap = box.get(key) as Map;
        courses.add(
          CourseModel.fromMap(
            Map<String, dynamic>.from({
              ...courseMap as Map<String, dynamic>,
              'id': key.toString().split('_')[1],
            }),
          ),
        );
      }
    }

    return courses;
  }

  static Future<void> deleteSemester(String semesterId) async {
    final semesterBox = _semestersBoxInstance;
    final coursesBox = _coursesBoxInstance;
    if (semesterBox == null || coursesBox == null) {
      throw Exception('Storage not initialized');
    }

    await semesterBox.delete(semesterId);

    // Delete associated courses
    final coursesToDelete = coursesBox.keys.where(
      (key) => key.toString().startsWith('${semesterId}_'),
    );
    await Future.wait(coursesToDelete.map((key) => coursesBox.delete(key)));
  }

  static Future<void> clear() async {
    final semesterBox = _semestersBoxInstance;
    final coursesBox = _coursesBoxInstance;
    if (semesterBox == null || coursesBox == null) {
      throw Exception('Storage not initialized');
    }

    await Future.wait([semesterBox.clear(), coursesBox.clear()]);
  }
}
