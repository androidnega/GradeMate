import '../models/degree_level.dart';

class ClassificationUtils {
  static String getClassification(DegreeLevel level, double cgpa) {
    switch (level) {
      case DegreeLevel.diploma:
      case DegreeLevel.hnd:
        if (cgpa >= 3.50) return "Distinction";
        if (cgpa >= 2.50) return "Credit";
        if (cgpa >= 1.00) return "Pass";
        return "Fail";

      case DegreeLevel.bTech:
        if (cgpa >= 3.50) return "First Class";
        if (cgpa >= 3.00) return "Second Class Upper";
        if (cgpa >= 2.50) return "Second Class Lower";
        if (cgpa >= 2.00) return "Third Class";
        if (cgpa >= 1.10) return "Pass";
        return "Fail";

      case DegreeLevel.mTech:
        return cgpa >= 2.50
            ? "Eligible for Graduation"
            : "Below Graduation Requirement";
    }
  }
}
