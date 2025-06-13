import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Semester operations
  static Future<String> addSemester(
    String userId,
    SemesterModel semester,
  ) async {
    try {
      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .add(semester.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add semester: $e');
    }
  }

  static Future<List<SemesterModel>> getSemesters(String userId) async {
    try {
      final querySnapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('semesters')
              .orderBy('created_at', descending: true)
              .get();

      List<SemesterModel> semesters = [];
      for (final doc in querySnapshot.docs) {
        final semester = SemesterModel.fromMap(doc.data(), doc.id);
        final courses = await getCourses(userId, doc.id);
        semesters.add(semester.copyWith(courses: courses));
      }
      return semesters;
    } catch (e) {
      throw Exception('Failed to get semesters: $e');
    }
  }

  static Future<void> updateSemester(
    String userId,
    String semesterId,
    SemesterModel semester,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .update(semester.toMap());
    } catch (e) {
      throw Exception('Failed to update semester: $e');
    }
  }

  static Future<void> deleteSemester(String userId, String semesterId) async {
    try {
      // Delete all courses in the semester first
      final coursesRef = _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses');

      final courses = await coursesRef.get();
      final batch = _db.batch();

      for (final doc in courses.docs) {
        batch.delete(doc.reference);
      }

      // Delete the semester
      batch.delete(
        _db
            .collection('users')
            .doc(userId)
            .collection('semesters')
            .doc(semesterId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete semester: $e');
    }
  }

  // Course operations
  static Future<String> addCourse(
    String userId,
    String semesterId,
    CourseModel course,
  ) async {
    try {
      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .add(course.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add course: $e');
    }
  }

  static Future<List<CourseModel>> getCourses(
    String userId,
    String semesterId,
  ) async {
    try {
      final querySnapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('semesters')
              .doc(semesterId)
              .collection('courses')
              .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CourseModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }

  static Future<void> updateCourse(
    String userId,
    String semesterId,
    String courseId,
    CourseModel course,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .update(course.toMap());
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  static Future<void> deleteCourse(
    String userId,
    String semesterId,
    String courseId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // GPA operations
  static Future<void> saveGpaResult({
    required String userId,
    required double gpa,
    required double cgpa,
    required String classification,
    required String semesterLabel,
    required String degreeLevel,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'gpa': gpa,
        'cgpa': cgpa,
        'classification': classification,
        'degreeLevel': degreeLevel,
        'semesterLabel': semesterLabel,
        'timestamp': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      };

      await _db
          .collection('users')
          .doc(userId)
          .collection('gpaResults')
          .add(data);
    } catch (e) {
      throw Exception('Failed to save GPA result: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getGpaResults(String userId) async {
    try {
      final querySnapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('gpaResults')
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get GPA results: $e');
    }
  }

  // Utility methods
  static Stream<List<SemesterModel>> semestersStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('semesters')
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<SemesterModel> semesters = [];
          for (final doc in snapshot.docs) {
            final semester = SemesterModel.fromMap(doc.data(), doc.id);
            final courses = await getCourses(userId, doc.id);
            semesters.add(semester.copyWith(courses: courses));
          }
          return semesters;
        });
  }

  static Stream<SemesterModel> semesterStream(
    String userId,
    String semesterId,
  ) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (!snapshot.exists) {
            throw Exception('Semester not found');
          }
          final semester = SemesterModel.fromMap(snapshot.data()!, snapshot.id);
          final courses = await getCourses(userId, semesterId);
          return semester.copyWith(courses: courses);
        });
  }

  static Stream<List<CourseModel>> coursesStream(
    String userId,
    String semesterId,
  ) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId)
        .collection('courses')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return CourseModel.fromMap(data);
              }).toList(),
        );
  }
}
