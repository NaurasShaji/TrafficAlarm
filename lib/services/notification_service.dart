import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static const String _channelId = 'traffic_alarm_channel';
  static const String _channelName = 'Traffic Alarm';
  static const String _channelDescription = 'Notifications for traffic-aware alarms';

  static Future<void> initialize() async {
    // Skip initialization on web platform or Windows (limited support)
    if (kIsWeb) {
      debugPrint('Notifications not supported on web platform');
      return;
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Notifications have limited support on desktop platforms');
      // Still initialize but don't fail if it doesn't work
      try {
        const InitializationSettings settings = InitializationSettings();
        await _notifications.initialize(settings);
      } catch (e) {
        debugPrint('Desktop notification initialization failed: $e');
      }
      return;
    }
    
    // Request notification permissions
    await _requestPermissions();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    await _createNotificationChannel();
  }
  
  static Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    
    await Permission.notification.request();
    
    // For Android 13+ (API level 33+), request POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  
  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
      sound: RawResourceAndroidNotificationSound('alarm_urgent'),
      enableLights: true,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_urgent.caf',
    ),
  );

  static const NotificationDetails _gentleNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
      sound: RawResourceAndroidNotificationSound('alarm_gentle'),
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_gentle.caf',
    ),
  );

  static Future<void> _createNotificationChannel() async {
    if (kIsWeb) return;
    
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }
  
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool isGentle = false,
  }) async {
    if (kIsWeb) {
      debugPrint('Web: Would schedule alarm - $title at $scheduledTime');
      return;
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Desktop: Would schedule alarm - $title at $scheduledTime');
      debugPrint('Note: Scheduled notifications are not fully supported on desktop platforms');
      return;
    }
    
    try {
      final notificationDetails = isGentle ? _gentleNotificationDetails : _notificationDetails;
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> scheduleGentleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await scheduleAlarm(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      isGentle: true,
    );
  }

  static Future<void> scheduleUrgentAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await scheduleAlarm(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      isGentle: false,
    );
  }
  
  static Future<void> cancelAlarm(int id) async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Cancel alarm not supported on this platform');
      return;
    }
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
  
  static Future<void> cancelAllAlarms() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Cancel all alarms not supported on this platform');
      return;
    }
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
  
  static Future<List<PendingNotificationRequest>> getPendingAlarms() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return [];
    }
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }
  
  static Future<void> rescheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime newScheduledTime,
  }) async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Desktop: Would reschedule alarm $id to $newScheduledTime');
      return;
    }
    
    try {
      await cancelAlarm(id);
      await scheduleAlarm(
        id: id,
        title: title,
        body: body,
        scheduledTime: newScheduledTime,
      );
    } catch (e) {
      debugPrint('Error rescheduling notification: $e');
    }
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }
  
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      debugPrint('Web: Would show notification - $title: $body');
      return;
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Desktop: Would show notification - $title: $body');
      // Try to show immediate notification on desktop, but don't fail if it doesn't work
      try {
        await _notifications.show(id, title, body, _notificationDetails);
      } catch (e) {
        debugPrint('Desktop notification failed: $e');
      }
      return;
    }
    
    try {
      await _notifications.show(
        id,
        title,
        body,
        _notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
    }
  }
}
