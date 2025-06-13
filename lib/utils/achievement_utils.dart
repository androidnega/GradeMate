import 'package:flutter/material.dart';

class AchievementUtils {
  static IconData getAchievementIcon(double gpa) {
    if (gpa >= 3.6) return Icons.emoji_events_rounded;
    if (gpa >= 3.0) return Icons.star_rounded;
    if (gpa >= 2.5) return Icons.thumb_up_rounded;
    return Icons.school_rounded;
  }

  static String getAchievementText(double gpa) {
    if (gpa >= 3.6) return 'Outstanding';
    if (gpa >= 3.0) return 'Excellent';
    if (gpa >= 2.5) return 'Good Work';
    return 'Keep Going';
  }

  static Color getAchievementColor(double gpa) {
    if (gpa >= 3.6) return Colors.amber;
    if (gpa >= 3.0) return Colors.lightGreenAccent;
    if (gpa >= 2.5) return Colors.lightBlue;
    return Colors.grey.shade400;
  }
}
