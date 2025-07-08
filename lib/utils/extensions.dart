import '../models/medicine.dart';
import '../models/allergy.dart';

extension MealTimingExtension on MealTiming {
  String get displayName {
    switch (this) {
      case MealTiming.beforeMeal:
        return 'ก่อนอาหาร';
      case MealTiming.afterMeal:
        return 'หลังอาหาร';
      case MealTiming.withMeal:
        return 'กับอาหาร';
      case MealTiming.anytime:
        return 'เวลาไหนก็ได้';
    }
  }
}

extension AllergySeverityExtension on AllergySeverity {
  String get displayName {
    switch (this) {
      case AllergySeverity.mild:
        return 'เล็กน้อย';
      case AllergySeverity.moderate:
        return 'ปานกลาง';
      case AllergySeverity.severe:
        return 'รุนแรง';
      case AllergySeverity.lifeThreatening:
        return 'อันตรายถึงชีวิต';
    }
  }
}