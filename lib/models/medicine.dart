class Medicine {
  final int? id;
  final String name;
  final String? description;
  final String? imagePath;
  final String? dosage;
  final MealTiming timing;
  final DateTime? expirationDate;
  final String? precautions;
  final String? notes;
  final bool isStarred;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    this.id,
    required this.name,
    this.description,
    this.imagePath,
    this.dosage,
    this.timing = MealTiming.anytime,
    this.expirationDate,
    this.precautions,
    this.notes,
    this.isStarred = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'dosage': dosage,
      'timing': timing.index,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'precautions': precautions,
      'notes': notes,
      'isStarred': isStarred ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imagePath: map['imagePath'],
      dosage: map['dosage'],
      timing: MealTiming.values[map['timing'] ?? 0],
      expirationDate: map['expirationDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDate'])
          : null,
      precautions: map['precautions'],
      notes: map['notes'],
      isStarred: map['isStarred'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}

enum MealTiming {
  beforeMeal,
  afterMeal,
  withMeal,
  anytime,
}