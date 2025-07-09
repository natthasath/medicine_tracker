import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/treatment_history.dart';
import '../services/database_service.dart';
import 'add_treatment_screen.dart';

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
    final treatments = await _databaseService.getAllTreatmentHistory();
    setState(() {
      _treatments = treatments;
      _isLoading = false;
    });
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
                  child: Text(
                    'ยังไม่มีประวัติการรักษา\nเพิ่มประวัติการใช้ยาของคุณ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _treatments.length,
                  itemBuilder: (context, index) {
                    return _buildTreatmentCard(_treatments[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTreatment,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTreatmentCard(TreatmentHistory treatment) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    treatment.medicineName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteTreatment(treatment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('ลบ', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'อาการ: ${treatment.condition}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            
            Text(
              'วันที่รักษา: ${dateFormat.format(treatment.treatmentDate)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            
            if (treatment.dosageTaken != null && treatment.dosageTaken!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'ขนาดยาที่รับประทาน: ${treatment.dosageTaken}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('ประสิทธิภาพ: '),
                ...List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < treatment.effectivenessRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ],
            ),
            
            if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'หมายเหตุ: ${treatment.notes}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addTreatment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTreatmentScreen(),
      ),
    );
    if (result == true) {
      _loadTreatmentHistory();
    }
  }

  Future<void> _deleteTreatment(TreatmentHistory treatment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบประวัติการรักษา'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบประวัติการรักษานี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteTreatmentHistory(treatment.id!);
      _loadTreatmentHistory();
    }
  }
}