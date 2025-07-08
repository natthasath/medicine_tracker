import '../models/medicine.dart';
import '../models/treatment_history.dart';
import '../models/allergy.dart';

class MemoryStorageService {
  static final MemoryStorageService _instance = MemoryStorageService._internal();
  
  factory MemoryStorageService() => _instance;
  MemoryStorageService._internal();

  // In-memory storage
  final List<Medicine> _medicines = [];
  final List<TreatmentHistory> _treatments = [];
  final List<Allergy> _allergies = [];
  
  int _nextMedicineId = 1;
  int _nextTreatmentId = 1;
  int _nextAllergyId = 1;

  // Medicine operations
  Future<int> insertMedicine(Medicine medicine) async {
    final id = _nextMedicineId++;
    final medicineWithId = Medicine(
      id: id,
      name: medicine.name,
      description: medicine.description,
      imagePath: medicine.imagePath,
      dosage: medicine.dosage,
      timing: medicine.timing,
      expirationDate: medicine.expirationDate,
      precautions: medicine.precautions,
      notes: medicine.notes,
      isStarred: medicine.isStarred,
      createdAt: medicine.createdAt,
      updatedAt: medicine.updatedAt,
    );
    
    _medicines.add(medicineWithId);
    print('💊 Medicine added to memory: ${medicine.name} (ID: $id)');
    return id;
  }

  Future<List<Medicine>> getAllMedicines() async {
    // Sort by starred first, then by name
    _medicines.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;
      return a.name.compareTo(b.name);
    });
    return List.from(_medicines);
  }

  Future<Medicine?> getMedicineById(int id) async {
    try {
      return _medicines.firstWhere((medicine) => medicine.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
      print('📝 Medicine updated in memory: ${medicine.name}');
      return 1; // Success
    }
    return 0; // Not found
  }

  Future<int> deleteMedicine(int id) async {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final medicine = _medicines.removeAt(index);
      print('🗑️ Medicine deleted from memory: ${medicine.name}');
      return 1; // Success
    }
    return 0; // Not found
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _medicines.where((medicine) {
      return medicine.name.toLowerCase().contains(lowercaseQuery) ||
          (medicine.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Treatment History operations
  Future<int> insertTreatmentHistory(TreatmentHistory treatment) async {
    final id = _nextTreatmentId++;
    final treatmentWithId = TreatmentHistory(
      id: id,
      medicineId: treatment.medicineId,
      medicineName: treatment.medicineName,
      treatmentDate: treatment.treatmentDate,
      condition: treatment.condition,
      dosageTaken: treatment.dosageTaken,
      effectivenessRating: treatment.effectivenessRating,
      notes: treatment.notes,
      createdAt: treatment.createdAt,
    );
    
    _treatments.add(treatmentWithId);
    return id;
  }

  Future<List<TreatmentHistory>> getAllTreatmentHistory() async {
    _treatments.sort((a, b) => b.treatmentDate.compareTo(a.treatmentDate));
    return List.from(_treatments);
  }

  Future<List<TreatmentHistory>> getTreatmentHistoryByMedicine(int medicineId) async {
    return _treatments.where((t) => t.medicineId == medicineId).toList();
  }

  Future<int> updateTreatmentHistory(TreatmentHistory treatment) async {
    final index = _treatments.indexWhere((t) => t.id == treatment.id);
    if (index != -1) {
      _treatments[index] = treatment;
      return 1;
    }
    return 0;
  }

  Future<int> deleteTreatmentHistory(int id) async {
    final index = _treatments.indexWhere((t) => t.id == id);
    if (index != -1) {
      _treatments.removeAt(index);
      return 1;
    }
    return 0;
  }

  // Allergy operations
  Future<int> insertAllergy(Allergy allergy) async {
    final id = _nextAllergyId++;
    final allergyWithId = Allergy(
      id: id,
      medicineName: allergy.medicineName,
      reactionType: allergy.reactionType,
      severity: allergy.severity,
      dateDiscovered: allergy.dateDiscovered,
      notes: allergy.notes,
      createdAt: allergy.createdAt,
      updatedAt: allergy.updatedAt,
    );
    
    _allergies.add(allergyWithId);
    return id;
  }

  Future<List<Allergy>> getAllAllergies() async {
    _allergies.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return a.medicineName.compareTo(b.medicineName);
    });
    return List.from(_allergies);
  }

  Future<int> updateAllergy(Allergy allergy) async {
    final index = _allergies.indexWhere((a) => a.id == allergy.id);
    if (index != -1) {
      _allergies[index] = allergy;
      return 1;
    }
    return 0;
  }

  Future<int> deleteAllergy(int id) async {
    final index = _allergies.indexWhere((a) => a.id == id);
    if (index != -1) {
      _allergies.removeAt(index);
      return 1;
    }
    return 0;
  }

  Future<bool> checkAllergyWarning(String medicineName) async {
    final lowercaseName = medicineName.toLowerCase();
    return _allergies.any((allergy) => 
        allergy.medicineName.toLowerCase().contains(lowercaseName));
  }

  // Utility methods
  Future<bool> isDatabaseReady() async {
    return true; // Memory storage is always ready
  }

  Future<void> clearAllData() async {
    _medicines.clear();
    _treatments.clear();
    _allergies.clear();
    _nextMedicineId = 1;
    _nextTreatmentId = 1;
    _nextAllergyId = 1;
    print('🧹 All memory data cleared');
  }

  // Add some sample data for testing
  Future<void> addSampleData() async {
    if (_medicines.isNotEmpty) return; // Don't add if data already exists
    
    print('📝 Adding sample data...');
    
    // Sample medicines
    await insertMedicine(Medicine(
      name: 'พาราเซตามอล',
      description: 'ยาลดไข้ แก้ปวด',
      dosage: '1 เม็ด',
      timing: MealTiming.anytime,
      expirationDate: DateTime.now().add(const Duration(days: 365)),
      precautions: 'ห้ามเกินวันละ 4 เม็ด',
      isStarred: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    
    await insertMedicine(Medicine(
      name: 'ยาแก้ไอ',
      description: 'แก้ไอ ลดเสมหะ',
      dosage: '5ml',
      timing: MealTiming.afterMeal,
      expirationDate: DateTime.now().add(const Duration(days: 180)),
      isStarred: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    
    print('✅ Sample data added');
  }
}