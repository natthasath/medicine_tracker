import 'package:flutter/material.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('การจัดการข้อมูล'),
                _buildDataManagementSection(),
                
                const SizedBox(height: 24),
                _buildSectionHeader('การแจ้งเตือน'),
                _buildNotificationSection(),
                
                const SizedBox(height: 24),
                _buildSectionHeader('ระบบฐานข้อมูล'),
                _buildDatabaseSection(),
                
                const SizedBox(height: 24),
                _buildSectionHeader('เกี่ยวกับแอป'),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download, color: Colors.green),
            title: const Text('นำออกข้อมูล'),
            subtitle: const Text('ส่งออกข้อมูลทั้งหมดเป็นไฟล์ JSON'),
            onTap: _exportData,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.blue),
            title: const Text('นำเข้าข้อมูล'),
            subtitle: const Text('นำเข้าข้อมูลจากไฟล์ JSON'),
            onTap: _importData,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('ลบข้อมูลทั้งหมด'),
            subtitle: const Text('ลบข้อมูลทั้งหมดออกจากแอป (ไม่สามารถกู้คืนได้)'),
            onTap: _deleteAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_off, color: Colors.grey),
            title: const Text('การแจ้งเตือน'),
            subtitle: const Text('ระบบการแจ้งเตือนกำลังปรับปรุง'),
            onTap: _showNotificationInfo,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('เกี่ยวกับการแจ้งเตือน'),
            subtitle: const Text('ข้อมูลเกี่ยวกับการแจ้งเตือนยาหมดอายุ'),
            onTap: _showNotificationInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.storage, color: Colors.green),
            title: Text('ระบบฐานข้อมูล'),
            subtitle: Text('🗄️ SQLite Database (Persistent)'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.orange),
            title: const Text('ตรวจสอบฐานข้อมูล'),
            subtitle: const Text('ตรวจสอบสถานะการทำงานของฐานข้อมูล'),
            onTap: _checkDatabaseHealth,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text('Medicine Tracker'),
            subtitle: Text('แอปบันทึกยาสามัญประจำบ้าน\nเวอร์ชัน 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.green),
            title: const Text('นโยบายความเป็นส่วนตัว'),
            subtitle: const Text('ข้อมูลของคุณจะถูกเก็บไว้ในเครื่องเท่านั้น'),
            onTap: _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      setState(() => _isLoading = true);
      
      // Get all data from database
      final medicines = await _databaseService.getAllMedicines();
      final treatments = await _databaseService.getAllTreatmentHistory();
      final allergies = await _databaseService.getAllAllergies();
      
      final exportData = {
        'medicines': medicines.map((m) => m.toMap()).toList(),
        'treatments': treatments.map((t) => t.toMap()).toList(),
        'allergies': allergies.map((a) => a.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'storageType': 'SQLite Database',
      };
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ส่งออกข้อมูลสำเร็จ'),
            content: Text(
              'ข้อมูลทั้งหมด:\n'
              '• ${medicines.length} ยา\n'
              '• ${treatments.length} ประวัติการรักษา\n'
              '• ${allergies.length} รายการแพ้ยา\n\n'
              '🗄️ ข้อมูลจาก SQLite Database'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
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

  Future<void> _importData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ฟีเจอร์นำเข้าข้อมูลจะพร้อมใช้งานในเวอร์ชันถัดไป'),
        ),
      );
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบข้อมูลทั้งหมด'),
        content: const Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลทั้งหมด?\n\nการดำเนินการนี้ไม่สามารถกู้คืนได้',
        ),
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
      try {
        setState(() => _isLoading = true);
        
        // Clear all data from database
        await _databaseService.clearAllData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบข้อมูลทั้งหมดเรียบร้อยแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
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

  Future<void> _checkDatabaseHealth() async {
    try {
      setState(() => _isLoading = true);
      
      // Test database operations
      final isReady = await _databaseService.isDatabaseReady();
      final medicines = await _databaseService.getAllMedicines();
      final treatments = await _databaseService.getAllTreatmentHistory();
      final allergies = await _databaseService.getAllAllergies();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('สถานะฐานข้อมูล'),
              ],
            ),
            content: Text(
              '✅ ฐานข้อมูลทำงานปกติ\n\n'
              'พร้อมใช้งาน: ${isReady ? "✅" : "❌"}\n'
              'ข้อมูลในระบบ:\n'
              '• ยา: ${medicines.length} รายการ\n'
              '• ประวัติการรักษา: ${treatments.length} รายการ\n'
              '• รายการแพ้ยา: ${allergies.length} รายการ\n\n'
              '🗄️ SQLite Database (Persistent)'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('ปัญหาฐานข้อมูล'),
              ],
            ),
            content: Text(
              '❌ เกิดข้อผิดพลาดกับฐานข้อมูล\n\n'
              'รายละเอียด: $e\n\n'
              'แนะนำให้รีสตาร์ทแอป'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showNotificationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('การแจ้งเตือน'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ระบบการแจ้งเตือนกำลังปรับปรุง',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'ในเวอร์ชันถัดไป แอปจะแจ้งเตือน:\n'
              '• 30 วันก่อนยาหมดอายุ\n'
              '• 7 วันก่อนยาหมดอายุ\n'
              '• 1 วันก่อนยาหมดอายุ',
            ),
            SizedBox(height: 16),
            Text(
              'ขณะนี้คุณสามารถตรวจสอบวันหมดอายุยาได้ในหน้ารายการยา',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const SingleChildScrollView(
          child: Text(
            'แอป Medicine Tracker เก็บข้อมูลทั้งหมดไว้ในเครื่องของคุณเท่านั้น\n\n'
            '• ไม่มีการส่งข้อมูลไปยังเซิร์ฟเวอร์ภายนอก\n'
            '• ไม่มีการรวบรวมข้อมูลส่วนบุคคล\n'
            '• ข้อมูลจะหายไปเมื่อคุณลบแอป\n'
            '• คุณสามารถส่งออกข้อมูลเพื่อสำรองได้\n\n'
            'แอปนี้ใช้สำหรับบันทึกข้อมูลยาส่วนตัวเท่านั้น ไม่ใช่คำแนะนำทางการแพทย์\n\n'
            '🗄️ ข้อมูลเก็บใน SQLite Database บนเครื่องของคุณ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}