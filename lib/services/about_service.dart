import 'package:cloud_firestore/cloud_firestore.dart';

class AboutService {
  static Future<Map<String, dynamic>?> fetchAboutData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('about')
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }
}
