import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'alarm_manager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'trafficCheckTask') {
      await BackgroundService._performTrafficCheck();
      return Future.value(true);
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static const String _trafficCheckTask = 'trafficCheckTask';
  static bool _initialized = false;

  /// Initialize the background service
  static Future<void> initialize() async {
    if (_initialized || kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _initialized = true;
      debugPrint('Background service: Skipping initialization on desktop platform');
      return;
    }

    try {
      // Initialize Workmanager for Android
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // Register periodic task (runs every 15 minutes)
      await Workmanager().registerPeriodicTask(
        'traffic_check_task',
        _trafficCheckTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      _initialized = true;
      debugPrint('Background service initialized');
    } catch (e) {
      debugPrint('Error initializing background service: $e');
    }
  }

  /// Perform traffic check
  static Future<bool> _performTrafficCheck() async {
    debugPrint('Running traffic check in background');
    try {
      // Initialize dependencies
      final alarmManager = AlarmManager();
      await alarmManager.initialize();

      // Check and update alarm based on traffic
      await alarmManager.updateAlarmBasedOnTraffic();
      return true;
    } catch (e) {
      debugPrint('Error in traffic check: $e');
      return false;
    }
  }
  
  /// Start the background service
  static Future<void> start() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Background service: Skipping on desktop platform');
      return;
    }
    
    if (!_initialized) {
      await initialize();
    }
    
    try {
      // Cancel any existing tasks to avoid duplicates
      await Workmanager().cancelAll();
      
      // Register the periodic task
      await Workmanager().registerPeriodicTask(
        'traffic_check_task',
        _trafficCheckTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      
      debugPrint('Background service started');
    } catch (e) {
      debugPrint('Error starting background service: $e');
    }
  }
  
  /// Stop the background service
  static Future<void> stop() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Background service: Skipping on desktop platform');
      return;
    }
    
    try {
      await Workmanager().cancelAll();
      debugPrint('Background service stopped');
    } catch (e) {
      debugPrint('Error stopping background service: $e');
    }
  }
  
  /// Run an immediate traffic check
  static Future<void> runImmediateCheck() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Desktop: Would run immediate traffic check');
      return;
    }
    
    try {
      await Workmanager().registerOneOffTask(
        'immediate_traffic_check',
        _trafficCheckTask,
        initialDelay: Duration.zero,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      debugPrint('Scheduled immediate traffic check');
    } catch (e) {
      debugPrint('Error scheduling immediate traffic check: $e');
    }
  }
}

