import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  Future<void> scheduleExpirationNotification(Medicine medicine) async {
    if (medicine.expirationDate == null || _flutterLocalNotificationsPlugin == null) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final expirationDate = tz.TZDateTime.from(medicine.expirationDate!, tz.local);
    
    // Schedule notifications for 30 days, 7 days, and 1 day before expiration
    final notificationDays = [30, 7, 1];
    
    for (int days in notificationDays) {
      final notificationDate = expirationDate.subtract(Duration(days: days));
      
      // Only schedule if the notification date is in the future
      if (notificationDate.isAfter(now)) {
        await _scheduleNotification(
          id: medicine.id! * 1000 + days, // Unique ID
          title: 'Medicine Expiration Alert',
          body: '${medicine.name} หมดอายุใน $days วัน${days > 1 ? '' : ''}',
          scheduledDate: notificationDate,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'medicine_expiration',
        'Medicine Expiration',
        channelDescription: 'Notifications for medicine expiration dates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      
      print('Scheduled notification: $id at $scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelMedicineNotifications(int medicineId) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    
    try {
      // Cancel all notifications for this medicine
      final notificationDays = [30, 7, 1];
      for (int days in notificationDays) {
        await _flutterLocalNotificationsPlugin!.cancel(medicineId * 1000 + days);
      }
      print('Cancelled notifications for medicine: $medicineId');
    } catch (e) {
      print('Error cancelling notifications: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (_flutterLocalNotificationsPlugin == null) return;
    
    try {
      await _flutterLocalNotificationsPlugin!.cancelAll();
      print('Cancelled all notifications');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  // Schedule immediate test notification
  Future<void> scheduleTestNotification() async {
    if (_flutterLocalNotificationsPlugin == null) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'medicine_expiration',
        'Medicine Expiration',
        channelDescription: 'Notifications for medicine expiration dates',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin!.show(
        999,
        'Test Notification',
        'Medicine Tracker notifications are working!',
        notificationDetails,
      );
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (_flutterLocalNotificationsPlugin == null) return [];
    
    try {
      return await _flutterLocalNotificationsPlugin!.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }
}