enum CalculationMode { gpa, cwa }

extension CalculationModeExtension on CalculationMode {
  String get label {
    switch (this) {
      case CalculationMode.gpa:
        return "GPA / CGPA";
      case CalculationMode.cwa:
        return "CWA";
    }
  }
}
