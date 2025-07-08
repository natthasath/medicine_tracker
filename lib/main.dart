import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/main_navigation_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Medicine Tracker App...');
  
  try {
    // Initialize storage service (will try database first, fallback to memory)
    print('🗄️ Initializing storage...');
    await StorageService().initialize();
    print('✅ Storage initialized successfully');
    
    // Initialize timezone data
    print('⏰ Initializing timezone data...');
    tz.initializeTimeZones();
    
    // Set local timezone
    final String timeZoneName = 'Asia/Bangkok';
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print('✅ Timezone set to: $timeZoneName');
  } catch (e) {
    print('❌ Initialization error: $e');
    // Continue anyway, don't block the app
  }
  
  print('📱 App ready');
  print('🎯 Running app...');
  runApp(const MedicineTrackerApp());
}

// Remove the _initializeDatabase function as it's no longer needed

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