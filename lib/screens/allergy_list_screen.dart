import 'package:flutter/material.dart';
import '../models/allergy.dart';
import '../services/database_service.dart';

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
    try {
      final allergies = await _databaseService.getAllAllergies();
      setState(() {
        _allergies = allergies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading allergies: $e');
    }
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'ยังไม่มีรายการแพ้ยา',
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
                  itemCount: _allergies.length,
                  itemBuilder: (context, index) {
                    final allergy = _allergies[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: allergy.getSeverityColor(),
                        ),
                        title: Text(allergy.medicineName),
                        subtitle: Text(allergy.reactionType),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: allergy.getSeverityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            allergy.getSeverityText(),
                            style: TextStyle(
                              color: allergy.getSeverityColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ฟีเจอร์เพิ่มรายการแพ้ยากำลังพัฒนา'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}