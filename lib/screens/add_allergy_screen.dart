import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/allergy.dart';
import '../services/database_service.dart';

class AddAllergyScreen extends StatefulWidget {
  final Allergy? allergy;

  const AddAllergyScreen({super.key, this.allergy});

  @override
  State<AddAllergyScreen> createState() => _AddAllergyScreenState();
}

class _AddAllergyScreenState extends State<AddAllergyScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  final _medicineNameController = TextEditingController();
  final _reactionTypeController = TextEditingController();
  final _notesController = TextEditingController();
  
  AllergySeverity _selectedSeverity = AllergySeverity.mild;
  DateTime _dateDiscovered = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.allergy != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final allergy = widget.allergy!;
    _medicineNameController.text = allergy.medicineName;
    _reactionTypeController.text = allergy.reactionType;
    _notesController.text = allergy.notes ?? '';
    _selectedSeverity = allergy.severity;
    _dateDiscovered = allergy.dateDiscovered;
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _reactionTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.allergy != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขรายการแพ้ยา' : 'เพิ่มรายการแพ้ยา'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ข้อมูลการแพ้ยามีความสำคัญต่อความปลอดภัยของคุณ กรุณากรอกข้อมูลให้ถูกต้องและครบถ้วน',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Medicine Name
                    TextFormField(
                      controller: _medicineNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อยาที่แพ้ *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุชื่อยาที่แพ้';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Reaction Type
                    TextFormField(
                      controller: _reactionTypeController,
                      decoration: const InputDecoration(
                        labelText: 'อาการแพ้ *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.healing),
                        hintText: 'เช่น ผื่นคัน, บวม, หายใจลำบาก',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุอาการแพ้';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Severity Level
                    const Text(
                      'ระดับความรุนแรง *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...AllergySeverity.values.map((severity) {
                      return RadioListTile<AllergySeverity>(
                        title: Text(_getSeverityText(severity)),
                        subtitle: Text(_getSeverityDescription(severity)),
                        value: severity,
                        groupValue: _selectedSeverity,
                        onChanged: (value) {
                          setState(() => _selectedSeverity = value!);
                        },
                        activeColor: _getSeverityColor(severity),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    
                    // Date Discovered
                    const Text(
                      'วันที่พบว่าแพ้ *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateDiscovered,
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
                            Text(DateFormat('dd/MM/yyyy').format(_dateDiscovered)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'หมายเหตุเพิ่มเติม',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                        hintText: 'รายละเอียดเพิ่มเติม เช่น การรักษาที่ได้รับ',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveAllergy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'อัพเดทรายการแพ้ยา' : 'บันทึกรายการแพ้ยา',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getSeverityText(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return 'เล็กน้อย';
      case AllergySeverity.moderate:
        return 'ปานกลาง';
      case AllergySeverity.severe:
        return 'รุนแรง';
      case AllergySeverity.lifeThreatening:
        return 'อันตรายถึงชีวิต';
      default: // Add this if missing
        return 'ไม่ระบุ';
    }
  }

  String _getSeverityDescription(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return 'อาการเล็กน้อย เช่น ผื่นคันเล็กน้อย';
      case AllergySeverity.moderate:
        return 'อาการปานกลาง เช่น ผื่นคันมาก บวม';
      case AllergySeverity.severe:
        return 'อาการรุนแรง เช่น หายใจลำบาก เป็นลม';
      case AllergySeverity.lifeThreatening:
        return 'อันตรายถึงชีวิต เช่น ช็อค หยุดหายใจ';
    }
  }

  Color _getSeverityColor(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return Colors.green;
      case AllergySeverity.moderate:
        return Colors.orange;
      case AllergySeverity.severe:
        return Colors.red;
      case AllergySeverity.lifeThreatening:
        return Colors.purple;
    }
  }

  Future<void> _selectDateDiscovered() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateDiscovered,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() => _dateDiscovered = selectedDate);
    }
  }

  Future<void> _saveAllergy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final allergy = Allergy(
        id: widget.allergy?.id,
        medicineName: _medicineNameController.text.trim(),
        reactionType: _reactionTypeController.text.trim(),
        severity: _selectedSeverity,
        dateDiscovered: _dateDiscovered,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.allergy?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.allergy == null) {
        await _databaseService.insertAllergy(allergy);
      } else {
        await _databaseService.updateAllergy(allergy);
      }

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
    } finally {
      setState(() => _isLoading = false);
    }
  }
}