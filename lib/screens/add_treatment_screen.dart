import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../models/treatment_history.dart';
import '../services/database_service.dart';

class AddTreatmentScreen extends StatefulWidget {
  const AddTreatmentScreen({super.key});

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  final _conditionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<Medicine> _medicines = [];
  Medicine? _selectedMedicine;
  DateTime _treatmentDate = DateTime.now();
  int _effectivenessRating = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final medicines = await _databaseService.getAllMedicines();
    setState(() {
      _medicines = medicines;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มประวัติการรักษา'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? const Center(
                  child: Text(
                    'คุณยังไม่มีรายการยา\nเพิ่มยาก่อนบันทึกประวัติการรักษา',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medicine Selection
                        const Text(
                          'เลือกยา *',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Medicine>(
                          value: _selectedMedicine,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medication),
                          ),
                          items: _medicines.map((medicine) {
                            return DropdownMenuItem(
                              value: medicine,
                              child: Text(medicine.name),
                            );
                          }).toList(),
                          onChanged: (medicine) {
                            setState(() {
                              _selectedMedicine = medicine;
                              if (medicine?.dosage != null) {
                                _dosageController.text = medicine!.dosage!;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'กรุณาเลือกยา';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Condition
                        TextFormField(
                          controller: _conditionController,
                          decoration: const InputDecoration(
                            labelText: 'อาการที่รักษา *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.healing),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณาระบุอาการที่รักษา';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Treatment Date
                        const Text(
                          'วันที่รักษา *',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectTreatmentDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(DateFormat('dd/MM/yyyy').format(_treatmentDate)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Dosage Taken
                        TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'ขนาดยาที่รับประทาน',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.colorize),
                            hintText: 'เช่น 1 เม็ด, 5ml',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Effectiveness Rating
                        const Text(
                          'ประสิทธิภาพของยา',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _effectivenessRating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  index < _effectivenessRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'หมายเหตุเพิ่มเติม',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notes),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveTreatment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'บันทึกประวัติการรักษา',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _selectTreatmentDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _treatmentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() => _treatmentDate = selectedDate);
    }
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final treatment = TreatmentHistory(
        medicineId: _selectedMedicine!.id!,
        medicineName: _selectedMedicine!.name,
        treatmentDate: _treatmentDate,
        condition: _conditionController.text.trim(),
        dosageTaken: _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        effectivenessRating: _effectivenessRating,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _databaseService.insertTreatmentHistory(treatment);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}