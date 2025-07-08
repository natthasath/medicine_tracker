import 'package:flutter/material.dart';
import '../models/treatment_history.dart';
import '../services/database_service.dart';

class TreatmentHistoryScreen extends StatefulWidget {
  const TreatmentHistoryScreen({super.key});

  @override
  State<TreatmentHistoryScreen> createState() => _TreatmentHistoryScreenState();
}

class _TreatmentHistoryScreenState extends State<TreatmentHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<TreatmentHistory> _treatments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatmentHistory();
  }

  Future<void> _loadTreatmentHistory() async {
    setState(() => _isLoading = true);
    try {
      final treatments = await _databaseService.getAllTreatmentHistory();
      setState(() {
        _treatments = treatments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading treatment history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการรักษา'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _treatments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'ยังไม่มีประวัติการรักษา',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ฟีเจอร์นี้กำลังพัฒนา',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _treatments.length,
                  itemBuilder: (context, index) {
                    final treatment = _treatments[index];
                    return ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(treatment.medicineName),
                      subtitle: Text(treatment.condition),
                      trailing: Text(
                        treatment.treatmentDate.day.toString().padLeft(2, '0') +
                        '/' +
                        treatment.treatmentDate.month.toString().padLeft(2, '0') +
                        '/' +
                        treatment.treatmentDate.year.toString(),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ฟีเจอร์เพิ่มประวัติการรักษากำลังพัฒนา'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}