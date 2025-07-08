import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleStar;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onDelete,
    required this.onToggleStar,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = _isExpiringSoon();
    final isExpired = _isExpired();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isExpired 
                ? Border.all(color: Colors.red, width: 2)
                : isExpiringSoon
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Medicine Image
                _buildMedicineImage(),
                const SizedBox(width: 12),
                
                // Medicine Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onToggleStar,
                            icon: Icon(
                              medicine.isStarred ? Icons.star : Icons.star_border,
                              color: medicine.isStarred ? Colors.amber : Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      
                      if (medicine.description != null && medicine.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            medicine.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Timing and Dosage
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.schedule,
                            label: _getMealTimingText(),
                            color: Colors.blue,
                          ),
                          if (medicine.dosage != null && medicine.dosage!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.medication,
                              label: medicine.dosage!,
                              color: Colors.green,
                            ),
                          ],
                        ],
                      ),
                      
                      // Expiration Date
                      if (medicine.expirationDate != null) ...[
                        const SizedBox(height: 8),
                        _buildExpirationInfo(),
                      ],
                    ],
                  ),
                ),
                
                // Action Menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onTap();
                        break;
                      case 'delete':
                        onDelete();
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
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: medicine.imagePath != null && medicine.imagePath!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(medicine.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.medication, size: 30, color: Colors.grey);
                },
              ),
            )
          : const Icon(Icons.medication, size: 30, color: Colors.grey),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final expirationText = dateFormat.format(medicine.expirationDate!);
    
    Color color;
    IconData icon;
    String prefix;
    
    if (_isExpired()) {
      color = Colors.red;
      icon = Icons.error;
      prefix = 'หมดอายุ: ';
    } else if (_isExpiringSoon()) {
      color = Colors.orange;
      icon = Icons.warning;
      prefix = 'ใกล้หมดอายุ: ';
    } else {
      color = Colors.grey;
      icon = Icons.calendar_today;
      prefix = 'หมดอายุ: ';
    }
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$prefix$expirationText',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getMealTimingText() {
    switch (medicine.timing) {
      case MealTiming.beforeMeal:
        return 'ก่อนอาหาร';
      case MealTiming.afterMeal:
        return 'หลังอาหาร';
      case MealTiming.withMeal:
        return 'กับอาหาร';
      case MealTiming.anytime:
        return 'เวลาไหนก็ได้';
      default:
        return 'เวลาไหนก็ได้'; // Add default case
    }
  }

  bool _isExpired() {
    if (medicine.expirationDate == null) return false;
    return medicine.expirationDate!.isBefore(DateTime.now());
  }

  bool _isExpiringSoon() {
    if (medicine.expirationDate == null) return false;
    final daysUntilExpiration = medicine.expirationDate!
        .difference(DateTime.now())
        .inDays;
    return daysUntilExpiration <= 30 && daysUntilExpiration >= 0;
  }
}