import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/allergy.dart';
import '../services/database_service.dart';
import 'add_allergy_screen.dart';

class AllergyListScreen extends StatefulWidget {
  const AllergyListScreen({super.key});

  @override
  State<AllergyListScreen> createState() => _AllergyListScreenState();
}

class _AllergyListScreenState extends State<AllergyListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Allergy> _allergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    setState(() => _isLoading = true);
    final allergies = await _databaseService.getAllAllergies();
    setState(() {
      _allergies = allergies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการแพ้ยา'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allergies.isEmpty
              ? const Center(
                  child: Text(
                    'ยังไม่มีรายการแพ้ยา\nเพิ่มข้อมูลการแพ้ยาเพื่อความปลอดภัย',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allergies.length,
                  itemBuilder: (context, index) {
                    return _buildAllergyCard(_allergies[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAllergy,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllergyCard(Allergy allergy) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: allergy.getSeverityColor(),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: allergy.getSeverityColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allergy.medicineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editAllergy(allergy);
                          break;
                        case 'delete':
                          _deleteAllergy(allergy);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('แก้ไข'),
                          ],
                        ),
                      ),
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
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: allergy.getSeverityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: allergy.getSeverityColor()),
                ),
                child: Text(
                  'ระดับความรุนแรง: ${allergy.getSeverityText()}',
                  style: TextStyle(
                    color: allergy.getSeverityColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              Text(
                'อาการแพ้: ${allergy.reactionType}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              
              Text(
                'วันที่พบ: ${dateFormat.format(allergy.dateDiscovered)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              
              if (allergy.notes != null && allergy.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'หมายเหตุ: ${allergy.notes}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _addAllergy() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAllergyScreen(),
      ),
    );
    if (result == true) {
      _loadAllergies();
    }
  }

  void _editAllergy(Allergy allergy) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAllergyScreen(allergy: allergy),
      ),
    );
    if (result == true) {
      _loadAllergies();
    }
  }

  Future<void> _deleteAllergy(Allergy allergy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการแพ้ยา'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบรายการแพ้ยา "${allergy.medicineName}"?'),
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
      await _databaseService.deleteAllergy(allergy.id!);
      _loadAllergies();
    }
  }
}