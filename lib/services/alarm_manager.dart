import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_settings.dart';
import 'traffic_service.dart';
import 'notification_service.dart';

class AlarmManager {
  static const String _alarmKey = 'alarm_settings';
  static final TrafficService _trafficService = TrafficService();
  
  AlarmSettings? _currentAlarm;
  bool _isInitialized = false;
  
  final StreamController<AlarmSettings?> _alarmController = 
      StreamController<AlarmSettings?>.broadcast();
  
  Stream<AlarmSettings?> get alarmStream => _alarmController.stream;
  AlarmSettings? get currentAlarm => _currentAlarm;
  bool get hasActiveAlarm => _currentAlarm?.isActive ?? false;
  
  static final AlarmManager _instance = AlarmManager._internal();
  
  factory AlarmManager() => _instance;
  
  AlarmManager._internal();
  
  Future<void> initialize() async {
    if (_isInitialized) {
      // Still emit current state to new listeners
      _alarmController.add(_currentAlarm);
      return;
    }
    
    debugPrint('AlarmManager: Starting initialization');
    await _loadAlarm();
    _isInitialized = true;
    debugPrint('AlarmManager: Initialization completed');
    
    // Always emit an initial value to ensure listeners receive something
    _alarmController.add(_currentAlarm);
  }
  
  Future<void> _loadAlarm() async {
    try {
      debugPrint('AlarmManager: Loading alarm settings');
      final prefs = await SharedPreferences.getInstance();
      final alarmData = prefs.getString(_alarmKey);
      
      if (alarmData != null) {
        try {
          final jsonData = jsonDecode(alarmData) as Map<String, dynamic>;
          _currentAlarm = AlarmSettings.fromJson(jsonData);
          debugPrint('AlarmManager: Loaded alarm - Active: ${_currentAlarm?.isActive}');
        } catch (e) {
          debugPrint('Error parsing alarm settings: $e');
          _currentAlarm = null;
        }
      } else {
        debugPrint('AlarmManager: No alarm settings found');
        _currentAlarm = null;
      }
    } catch (e) {
      debugPrint('Error loading alarm: $e');
      _currentAlarm = null;
    }
  }
  
  Future<void> _saveAlarm(AlarmSettings? alarm) async {
    _currentAlarm = alarm;
    _alarmController.add(_currentAlarm);
    
    final prefs = await SharedPreferences.getInstance();
    
    if (alarm != null) {
      await prefs.setString(_alarmKey, jsonEncode(alarm.toJson()));
    } else {
      await prefs.remove(_alarmKey);
    }
  }
  
  Future<void> setAlarm({
    required String destination,
    required DateTime arrivalTime,
    required int bufferMinutes,
  }) async {
    try {
      // Get traffic data
      final trafficData = await _trafficService.getTrafficData(destination);
      
      // Calculate alarm time
      final alarmTime = _trafficService.calculateAlarmTime(
        arrivalTime: arrivalTime,
        bufferMinutes: bufferMinutes,
        trafficData: trafficData,
      );
      
      // Create new alarm
      final newAlarm = AlarmSettings(
        destination: destination,
        arrivalTime: arrivalTime,
        bufferMinutes: bufferMinutes,
        calculatedAlarmTime: alarmTime,
        isActive: true,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      
      // Save alarm
      await _saveAlarm(newAlarm);
      
      // Schedule notifications
      // Schedule gentle alarm 10 minutes before
      final gentleAlarmTime = alarmTime.subtract(const Duration(minutes: 10));
      if (gentleAlarmTime.isAfter(DateTime.now())) {
        await NotificationService.scheduleGentleAlarm(
          id: 0, // ID for gentle alarm
          title: 'Get ready to leave',
          body: 'Start preparing - you need to leave for $destination in 10 minutes',
          scheduledTime: gentleAlarmTime,
        );
      }
      
      // Schedule urgent alarm at calculated time
      await NotificationService.scheduleUrgentAlarm(
        id: 1, // Use a fixed ID for the main urgent alarm
        title: 'Time to leave!',
        body: 'Leave now to reach $destination by ${_formatTime(arrivalTime)}',
        scheduledTime: alarmTime,
      );
      
      // Schedule traffic check (if not on web)
      if (!kIsWeb) {
        _scheduleTrafficCheck();
      }
      
      return;
    } catch (e) {
      debugPrint('Error setting alarm: $e');
      rethrow;
    }
  }
  
  Future<void> cancelAlarm() async {
    if (_currentAlarm == null) return;
    
    try {
      // Cancel any pending notifications
      await NotificationService.cancelAlarm(0); // Gentle alarm
      await NotificationService.cancelAlarm(1); // Urgent alarm
      
      // Cancel any pending traffic checks
      if (!kIsWeb) {
        _cancelTrafficCheck();
      }
      
      // Clear the alarm
      await _saveAlarm(null);
    } catch (e) {
      debugPrint('Error canceling alarm: $e');
      rethrow;
    }
  }
  
  Future<void> updateAlarmBasedOnTraffic() async {
    if (_currentAlarm == null || !_currentAlarm!.isActive) return;
    
    try {
      final alarm = _currentAlarm!;
      final trafficData = await _trafficService.getTrafficData(alarm.destination);
      
      // Check if we need to adjust the alarm
      if (_trafficService.shouldAdjustAlarm(
        currentAlarmTime: alarm.calculatedAlarmTime!,
        arrivalTime: alarm.arrivalTime,
        bufferMinutes: alarm.bufferMinutes,
        newTrafficData: trafficData,
      )) {
        // Calculate new alarm time
        final newAlarmTime = _trafficService.calculateAlarmTime(
          arrivalTime: alarm.arrivalTime,
          bufferMinutes: alarm.bufferMinutes,
          trafficData: trafficData,
        );
        
        // Update alarm
        final updatedAlarm = alarm.copyWith(
          calculatedAlarmTime: newAlarmTime,
        );
        
        await _saveAlarm(updatedAlarm);
        
        // Reschedule notification
await NotificationService.rescheduleAlarm(
          id: 1,
          title: 'Alarm Adjusted - Time to leave!',
          body: 'Leave now to reach ${alarm.destination} by ${_formatTime(alarm.arrivalTime)}',
          newScheduledTime: newAlarmTime,
        );
        
        // Show immediate notification about the adjustment
await NotificationService.showImmediateNotification(
          id: 2, // Different ID to not conflict with main alarm
          title: 'Alarm Adjusted',
          body: 'Your alarm has been adjusted to ${_formatTime(newAlarmTime)} due to traffic conditions.',
        );
      }
    } catch (e) {
      debugPrint('Error updating alarm based on traffic: $e');
    }
  }
  
  void _scheduleTrafficCheck() {
    if (kIsWeb) return;
    
    // Cancel any existing traffic checks
    _cancelTrafficCheck();
    
    // Schedule next traffic check
    // In a real app, you might use Workmanager for background tasks
    // For this example, we'll just log that we would check traffic
    debugPrint('Scheduling next traffic check...');
  }
  
  void _cancelTrafficCheck() {
    if (kIsWeb) return;
    // Cancel any pending traffic checks
    debugPrint('Canceling traffic checks');
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  void dispose() {
    _alarmController.close();
  }
}
