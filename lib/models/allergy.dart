import 'package:flutter/material.dart'; // Add this import

enum AllergySeverity {
  mild,
  moderate,
  severe,
  lifeThreatening,
}

class Allergy {
  final int? id;
  final String medicineName;
  final String reactionType;
  final AllergySeverity severity;
  final DateTime dateDiscovered;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Allergy({
    this.id,
    required this.medicineName,
    required this.reactionType,
    required this.severity,
    required this.dateDiscovered,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineName': medicineName,
      'reactionType': reactionType,
      'severity': severity.index,
      'dateDiscovered': dateDiscovered.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Allergy.fromMap(Map<String, dynamic> map) {
    return Allergy(
      id: map['id'],
      medicineName: map['medicineName'],
      reactionType: map['reactionType'],
      severity: AllergySeverity.values[map['severity'] ?? 0],
      dateDiscovered: DateTime.fromMillisecondsSinceEpoch(map['dateDiscovered']),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  String getSeverityText() {
    switch (severity) {
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

  Color getSeverityColor() {
    switch (severity) {
      case AllergySeverity.mild:
        return Colors.green;
      case AllergySeverity.moderate:
        return Colors.orange;
      case AllergySeverity.severe:
        return Colors.red;
      case AllergySeverity.lifeThreatening:
        return Colors.purple;
    }
  }
}