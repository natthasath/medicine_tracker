import '../models/medicine.dart';
import '../models/treatment_history.dart';
import '../models/allergy.dart';
import 'database_service.dart';
import 'memory_storage_service.dart';

enum StorageType { database, memory }

class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() => _instance;
  StorageService._internal();

  late final dynamic _activeService;
  late final StorageType _storageType;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔧 Initializing storage service...');
    
    try {
      // Try to initialize database service first
      print('🗄️ Attempting to use database storage...');
      final dbService = DatabaseService();
      
      // Test database connection
      await dbService.isDatabaseReady();
      await dbService.getAllMedicines(); // Test a simple query
      
      _activeService = dbService;
      _storageType = StorageType.database;
      print('✅ Database storage initialized successfully');
    } catch (e) {
      print('❌ Database storage failed: $e');
      print('🔄 Falling back to memory storage...');
      
      // Fallback to memory storage
      final memoryService = MemoryStorageService();
      await memoryService.addSampleData(); // Add some sample data
      
      _activeService = memoryService;
      _storageType = StorageType.memory;
      print('✅ Memory storage initialized successfully');
    }
    
    _isInitialized = true;
    print('🎯 Storage service ready (Type: $_storageType)');
  }

  StorageType get storageType => _storageType;
  bool get isUsingDatabase => _storageType == StorageType.database;
  bool get isUsingMemory => _storageType == StorageType.memory;

  // Ensure service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Medicine operations
  Future<int> insertMedicine(Medicine medicine) async {
    await _ensureInitialized();
    return await _activeService.insertMedicine(medicine);
  }

  Future<List<Medicine>> getAllMedicines() async {
    await _ensureInitialized();
    return await _activeService.getAllMedicines();
  }

  Future<Medicine?> getMedicineById(int id) async {
    await _ensureInitialized();
    return await _activeService.getMedicineById(id);
  }

  Future<int> updateMedicine(Medicine medicine) async {
    await _ensureInitialized();
    return await _activeService.updateMedicine(medicine);
  }

  Future<int> deleteMedicine(int id) async {
    await _ensureInitialized();
    return await _activeService.deleteMedicine(id);
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    await _ensureInitialized();
    return await _activeService.searchMedicines(query);
  }

  // Treatment History operations
  Future<int> insertTreatmentHistory(TreatmentHistory treatment) async {
    await _ensureInitialized();
    return await _activeService.insertTreatmentHistory(treatment);
  }

  Future<List<TreatmentHistory>> getAllTreatmentHistory() async {
    await _ensureInitialized();
    return await _activeService.getAllTreatmentHistory();
  }

  Future<List<TreatmentHistory>> getTreatmentHistoryByMedicine(int medicineId) async {
    await _ensureInitialized();
    return await _activeService.getTreatmentHistoryByMedicine(medicineId);
  }

  Future<int> updateTreatmentHistory(TreatmentHistory treatment) async {
    await _ensureInitialized();
    return await _activeService.updateTreatmentHistory(treatment);
  }

  Future<int> deleteTreatmentHistory(int id) async {
    await _ensureInitialized();
    return await _activeService.deleteTreatmentHistory(id);
  }

  // Allergy operations
  Future<int> insertAllergy(Allergy allergy) async {
    await _ensureInitialized();
    return await _activeService.insertAllergy(allergy);
  }

  Future<List<Allergy>> getAllAllergies() async {
    await _ensureInitialized();
    return await _activeService.getAllAllergies();
  }

  Future<int> updateAllergy(Allergy allergy) async {
    await _ensureInitialized();
    return await _activeService.updateAllergy(allergy);
  }

  Future<int> deleteAllergy(int id) async {
    await _ensureInitialized();
    return await _activeService.deleteAllergy(id);
  }

  Future<bool> checkAllergyWarning(String medicineName) async {
    await _ensureInitialized();
    return await _activeService.checkAllergyWarning(medicineName);
  }

  // Utility methods
  Future<bool> isDatabaseReady() async {
    await _ensureInitialized();
    return await _activeService.isDatabaseReady();
  }

  Future<void> clearAllData() async {
    await _ensureInitialized();
    return await _activeService.clearAllData();
  }

  // Get storage info for display
  String getStorageInfo() {
    if (!_isInitialized) return 'Not initialized';
    
    switch (_storageType) {
      case StorageType.database:
        return 'SQLite Database (Persistent)';
      case StorageType.memory:
        return 'Memory Storage (Session only)';
    }
  }

  // Force reload storage type (for debugging)
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
}