import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/main_navigation_screen.dart';
import 'services/database_service.dart';

void main() async {
  // CRITICAL: Must be called first
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Medicine Tracker App...');
  
  try {
    // Initialize database service
    print('🗄️ Initializing database...');
    final databaseService = DatabaseService();
    
    // Show platform information
    print('🖥️ Platform: ${databaseService.getPlatformInfo()}');
    
    await databaseService.initialize();
    
    // Test database
    final isReady = await databaseService.isDatabaseReady();
    print('🔍 Database ready: $isReady');
    
    if (isReady) {
      final medicines = await databaseService.getAllMedicines();
      print('📊 Found ${medicines.length} medicines in database');
      print('✅ Database initialization successful');
    } else {
      print('⚠️ Database may not be fully ready');
    }
    
    // Initialize timezone data
    print('⏰ Initializing timezone data...');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    print('✅ Timezone initialized');
    
  } catch (e) {
    print('❌ Initialization error: $e');
    print('🔄 App will continue but may have limited functionality');
  }
  
  print('📱 Starting app...');
  runApp(const MedicineTrackerApp());
}

class MedicineTrackerApp extends StatelessWidget {
  const MedicineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building MedicineTrackerApp...');
    
    return MaterialApp(
      title: 'Medicine Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}