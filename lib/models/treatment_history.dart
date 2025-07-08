class TreatmentHistory {
  final int? id;
  final int medicineId;
  final String medicineName; // For easy display
  final DateTime treatmentDate;
  final String condition;
  final String? dosageTaken;
  final int effectivenessRating; // 1-5 stars
  final String? notes;
  final DateTime createdAt;

  TreatmentHistory({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.treatmentDate,
    required this.condition,
    this.dosageTaken,
    this.effectivenessRating = 3,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'treatmentDate': treatmentDate.millisecondsSinceEpoch,
      'condition': condition,
      'dosageTaken': dosageTaken,
      'effectivenessRating': effectivenessRating,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TreatmentHistory.fromMap(Map<String, dynamic> map) {
    return TreatmentHistory(
      id: map['id'],
      medicineId: map['medicineId'],
      medicineName: map['medicineName'],
      treatmentDate: DateTime.fromMillisecondsSinceEpoch(map['treatmentDate']),
      condition: map['condition'],
      dosageTaken: map['dosageTaken'],
      effectivenessRating: map['effectivenessRating'] ?? 3,
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}