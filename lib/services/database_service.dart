import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/treatment_history.dart';
import '../models/allergy.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _isInitialized = false;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDatabase();
      _isInitialized = true;
      return _database!;
    } catch (e) {
      print('Database initialization error: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      print('🗄️ Getting database path...');
      String path = join(await getDatabasesPath(), 'medicine_tracker.db');
      print('📁 Database path: $path');
      
      print('🔧 Opening database...');
      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
        onOpen: (db) {
          print('✅ Database opened successfully');
        },
      );
      
      print('✅ Database initialized successfully');
      return db;
    } catch (e) {
      print('❌ Database initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    print('🏗️ Creating database tables...');
    
    try {
      // Medicines table
      await db.execute('''
        CREATE TABLE medicines(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          imagePath TEXT,
          dosage TEXT,
          timing INTEGER DEFAULT 0,
          expirationDate INTEGER,
          precautions TEXT,
          notes TEXT,
          isStarred INTEGER DEFAULT 0,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
      print('✅ Medicines table created');

      // Treatment History table
      await db.execute('''
        CREATE TABLE treatment_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineId INTEGER NOT NULL,
          medicineName TEXT NOT NULL,
          treatmentDate INTEGER NOT NULL,
          condition TEXT NOT NULL,
          dosageTaken TEXT,
          effectivenessRating INTEGER DEFAULT 3,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE
        )
      ''');
      print('✅ Treatment history table created');

      // Allergies table
      await db.execute('''
        CREATE TABLE allergies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineName TEXT NOT NULL,
          reactionType TEXT NOT NULL,
          severity INTEGER DEFAULT 0,
          dateDiscovered INTEGER NOT NULL,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
      print('✅ Allergies table created');
      
      print('🎉 All tables created successfully');
    } catch (e) {
      print('❌ Error creating tables: $e');
      rethrow;
    }
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      try {
        // Add new tables for version 2
        await db.execute('''
          CREATE TABLE IF NOT EXISTS treatment_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicineId INTEGER NOT NULL,
            medicineName TEXT NOT NULL,
            treatmentDate INTEGER NOT NULL,
            condition TEXT NOT NULL,
            dosageTaken TEXT,
            effectivenessRating INTEGER DEFAULT 3,
            notes TEXT,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS allergies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicineName TEXT NOT NULL,
            reactionType TEXT NOT NULL,
            severity INTEGER DEFAULT 0,
            dateDiscovered INTEGER NOT NULL,
            notes TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');
        
        print('✅ Database upgrade completed');
      } catch (e) {
        print('❌ Error upgrading database: $e');
        rethrow;
      }
    }
  }

  // Helper method to check if database is ready
  Future<bool> isDatabaseReady() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      print('Database readiness check failed: $e');
      return false;
    }
  }

  // ===== MEDICINE CRUD OPERATIONS =====
  Future<int> insertMedicine(Medicine medicine) async {
    try {
      final db = await database;
      final id = await db.insert('medicines', medicine.toMap());
      print('💊 Medicine added: ${medicine.name} (ID: $id)');
      return id;
    } catch (e) {
      print('❌ Error inserting medicine: $e');
      rethrow;
    }
  }

  Future<List<Medicine>> getAllMedicines() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medicines',
        orderBy: 'isStarred DESC, name ASC',
      );
      final medicines = List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
      print('📋 Loaded ${medicines.length} medicines');
      return medicines;
    } catch (e) {
      print('❌ Error getting medicines: $e');
      return []; // Return empty list instead of throwing
    }
  }

  Future<Medicine?> getMedicineById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medicines',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Medicine.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting medicine by ID: $e');
      return null;
    }
  }

  Future<int> updateMedicine(Medicine medicine) async {
    try {
      final db = await database;
      final result = await db.update(
        'medicines',
        medicine.toMap(),
        where: 'id = ?',
        whereArgs: [medicine.id],
      );
      print('📝 Medicine updated: ${medicine.name}');
      return result;
    } catch (e) {
      print('❌ Error updating medicine: $e');
      rethrow;
    }
  }

  Future<int> deleteMedicine(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'medicines',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('🗑️ Medicine deleted: ID $id');
      return result;
    } catch (e) {
      print('❌ Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medicines',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'isStarred DESC, name ASC',
      );
      return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error searching medicines: $e');
      return [];
    }
  }

  // ===== TREATMENT HISTORY CRUD OPERATIONS =====
  Future<int> insertTreatmentHistory(TreatmentHistory treatment) async {
    try {
      final db = await database;
      return await db.insert('treatment_history', treatment.toMap());
    } catch (e) {
      print('❌ Error inserting treatment history: $e');
      rethrow;
    }
  }

  Future<List<TreatmentHistory>> getAllTreatmentHistory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'treatment_history',
        orderBy: 'treatmentDate DESC',
      );
      return List.generate(maps.length, (i) => TreatmentHistory.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error getting treatment history: $e');
      return [];
    }
  }

  Future<List<TreatmentHistory>> getTreatmentHistoryByMedicine(int medicineId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'treatment_history',
        where: 'medicineId = ?',
        whereArgs: [medicineId],
        orderBy: 'treatmentDate DESC',
      );
      return List.generate(maps.length, (i) => TreatmentHistory.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error getting treatment history by medicine: $e');
      return [];
    }
  }

  Future<int> updateTreatmentHistory(TreatmentHistory treatment) async {
    try {
      final db = await database;
      return await db.update(
        'treatment_history',
        treatment.toMap(),
        where: 'id = ?',
        whereArgs: [treatment.id],
      );
    } catch (e) {
      print('❌ Error updating treatment history: $e');
      rethrow;
    }
  }

  Future<int> deleteTreatmentHistory(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'treatment_history',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting treatment history: $e');
      rethrow;
    }
  }

  // ===== ALLERGY CRUD OPERATIONS =====
  Future<int> insertAllergy(Allergy allergy) async {
    try {
      final db = await database;
      return await db.insert('allergies', allergy.toMap());
    } catch (e) {
      print('❌ Error inserting allergy: $e');
      rethrow;
    }
  }

  Future<List<Allergy>> getAllAllergies() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'allergies',
        orderBy: 'severity DESC, medicineName ASC',
      );
      return List.generate(maps.length, (i) => Allergy.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error getting allergies: $e');
      return [];
    }
  }

  Future<int> updateAllergy(Allergy allergy) async {
    try {
      final db = await database;
      return await db.update(
        'allergies',
        allergy.toMap(),
        where: 'id = ?',
        whereArgs: [allergy.id],
      );
    } catch (e) {
      print('❌ Error updating allergy: $e');
      rethrow;
    }
  }

  Future<int> deleteAllergy(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'allergies',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting allergy: $e');
      rethrow;
    }
  }

  Future<bool> checkAllergyWarning(String medicineName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'allergies',
        where: 'LOWER(medicineName) LIKE LOWER(?)',
        whereArgs: ['%$medicineName%'],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('❌ Error checking allergy warning: $e');
      return false; // Return false instead of throwing
    }
  }

  // Utility method to clear all data (for debugging)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('medicines');
      await db.delete('treatment_history');
      await db.delete('allergies');
      print('🧹 All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}