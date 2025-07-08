import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _precautionsController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  MealTiming _selectedTiming = MealTiming.anytime;
  DateTime? _expirationDate;
  String? _imagePath;
  bool _isStarred = false;
  bool _isLoading = false;
  bool _hasAllergyWarning = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _populateForm();
    }
    // Listen to name changes to check for allergies
    _nameController.addListener(_checkAllergyWarning);
  }

  void _populateForm() {
    final medicine = widget.medicine!;
    _nameController.text = medicine.name;
    _descriptionController.text = medicine.description ?? '';
    _dosageController.text = medicine.dosage ?? '';
    _precautionsController.text = medicine.precautions ?? '';
    _notesController.text = medicine.notes ?? '';
    _selectedTiming = medicine.timing;
    _expirationDate = medicine.expirationDate;
    _imagePath = medicine.imagePath;
    _isStarred = medicine.isStarred;
  }

  Future<void> _checkAllergyWarning() async {
    final medicineName = _nameController.text.trim();
    if (medicineName.isNotEmpty) {
      try {
        final hasAllergy = await _databaseService.checkAllergyWarning(medicineName);
        if (mounted) {
          setState(() => _hasAllergyWarning = hasAllergy);
        }
      } catch (e) {
        // Ignore allergy check errors
        setState(() => _hasAllergyWarning = false);
      }
    } else {
      setState(() => _hasAllergyWarning = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _precautionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicine != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: () {
                setState(() => _isStarred = !_isStarred);
              },
              icon: Icon(
                _isStarred ? Icons.star : Icons.star_border,
                color: _isStarred ? Colors.amber : Colors.white,
              ),
            ),
        ],
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
                    // Allergy Warning Banner
                    if (_hasAllergyWarning) _buildAllergyWarning(),
                    
                    // Medicine Image
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    
                    // Medicine Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.medication),
                        suffixIcon: _hasAllergyWarning 
                            ? const Icon(Icons.warning, color: Colors.red)
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter medicine name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Dosage
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 1 tablet, 5ml)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.colorize),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Meal Timing
                    _buildMealTimingSection(),
                    const SizedBox(height: 16),
                    
                    // Expiration Date
                    _buildExpirationDateSection(),
                    const SizedBox(height: 16),
                    
                    // Precautions
                    TextFormField(
                      controller: _precautionsController,
                      decoration: const InputDecoration(
                        labelText: 'Precautions',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
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
                        onPressed: _hasAllergyWarning ? _showAllergyConfirmation : _saveMedicine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasAllergyWarning ? Colors.orange : Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_hasAllergyWarning) ...[
                              const Icon(Icons.warning, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isEditing ? 'Update Medicine' : 'Add Medicine',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAllergyWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '⚠️ คำเตือน: คุณมีประวัติแพ้ยานี้!\nกรุณาตรวจสอบความปลอดภัยก่อนใช้',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: _imagePath != null && _imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 50, color: Colors.grey),
                            Text('Error loading image'),
                          ],
                        );
                      },
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
        if (_imagePath != null && _imagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => setState(() => _imagePath = null),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Remove photo', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }

  Widget _buildMealTimingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เวลาที่ควรทานยา',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MealTiming.values.map((timing) {
            return ChoiceChip(
              label: Text(_getMealTimingText(timing)),
              selected: _selectedTiming == timing,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedTiming = timing);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpirationDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'วันหมดอายุ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectExpirationDate,
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
                Text(
                  _expirationDate != null
                      ? DateFormat('dd/MM/yyyy').format(_expirationDate!)
                      : 'Select expiration date',
                  style: TextStyle(
                    color: _expirationDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (_expirationDate != null)
                  IconButton(
                    onPressed: () => setState(() => _expirationDate = null),
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getMealTimingText(MealTiming timing) {
    switch (timing) {
      case MealTiming.beforeMeal:
        return 'ก่อนอาหาร';
      case MealTiming.afterMeal:
        return 'หลังอาหาร';
      case MealTiming.withMeal:
        return 'กับอาหาร';
      case MealTiming.anytime:
        return 'เวลาไหนก็ได้';
      default:
        return 'เวลาไหนก็ได้';
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectExpirationDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );

    if (selectedDate != null) {
      setState(() {
        _expirationDate = selectedDate;
      });
    }
  }

  Future<void> _showAllergyConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('คำเตือนการแพ้ยา'),
          ],
        ),
        content: Text(
          'คุณมีประวัติแพ้ยา "${_nameController.text.trim()}" อยู่ในระบบ\n\n'
          'คุณแน่ใจหรือไม่ว่าต้องการเพิ่มยานี้?\n\n'
          'กรุณาปรึกษาแพทย์หรือเภสัชกรก่อนใช้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            child: const Text(
              'เพิ่มต่อไป',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _saveMedicine();
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final medicine = Medicine(
        id: widget.medicine?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imagePath: _imagePath,
        dosage: _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        timing: _selectedTiming,
        expirationDate: _expirationDate,
        precautions: _precautionsController.text.trim().isEmpty
            ? null
            : _precautionsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isStarred: _isStarred,
        createdAt: widget.medicine?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.medicine == null) {
        await _databaseService.insertMedicine(medicine);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${medicine.name} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _databaseService.updateMedicine(medicine);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${medicine.name} updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}