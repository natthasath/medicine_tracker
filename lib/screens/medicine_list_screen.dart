import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';
import 'add_edit_medicine_screen.dart';
import '../widgets/medicine_card.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      print('📱 Loading medicines from database...');
      
      // Load medicines directly from database
      final medicines = await _databaseService.getAllMedicines();
      
      setState(() {
        _medicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
      
      print('✅ Medicines loaded successfully: ${medicines.length} items');
      print('📁 Storage: SQLite Database (Persistent)');
      
    } catch (e) {
      print('❌ Error loading medicines: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Database Error'),
                const SizedBox(height: 4),
                Text('$e'),
                const SizedBox(height: 8),
                const Text('Try restarting the app or check Settings > Debug'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadMedicines,
            ),
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicines = _medicines.where((medicine) {
        return medicine.name.toLowerCase().contains(query) ||
            (medicine.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Medicines'),
            Text(
              '🗄️ ${_databaseService.getPlatformInfo()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading medicines from database...'),
                ],
              ),
            )
          : _filteredMedicines.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredMedicines.length,
                  itemBuilder: (context, index) {
                    return MedicineCard(
                      medicine: _filteredMedicines[index],
                      onTap: () => _editMedicine(_filteredMedicines[index]),
                      onDelete: () => _deleteMedicine(_filteredMedicines[index]),
                      onToggleStar: () => _toggleStar(_filteredMedicines[index]),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicine,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.medication,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'ไม่พบยาที่ค้นหา' : 'ยังไม่มีรายการยา',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'ลองค้นหาด้วยคำอื่น'
                : 'กดปุ่ม + เพื่อเพิ่มยาใหม่',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🗄️ SQLite Database (Persistent)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _addMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditMedicineScreen(),
      ),
    );
    if (result == true) {
      _loadMedicines();
    }
  }

  void _editMedicine(Medicine medicine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMedicineScreen(medicine: medicine),
      ),
    );
    if (result == true) {
      _loadMedicines();
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteMedicine(medicine.id!);
        _loadMedicines();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${medicine.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting medicine: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleStar(Medicine medicine) async {
    try {
      final updatedMedicine = Medicine(
        id: medicine.id,
        name: medicine.name,
        description: medicine.description,
        imagePath: medicine.imagePath,
        dosage: medicine.dosage,
        timing: medicine.timing,
        expirationDate: medicine.expirationDate,
        precautions: medicine.precautions,
        notes: medicine.notes,
        isStarred: !medicine.isStarred,
        createdAt: medicine.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _databaseService.updateMedicine(updatedMedicine);
      _loadMedicines();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}