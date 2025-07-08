import 'package:flutter/material.dart';
import 'medicine_list_screen.dart';
import 'treatment_history_screen.dart';
import 'allergy_list_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MedicineListScreen(),
    const TreatmentHistoryScreen(),
    const AllergyListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'ยา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'ประวัติการรักษา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'รายการแพ้ยา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }
}