import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize services
  await _initializeServices();
  
  // Run the app
  runApp(const TrafficAlarmApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize notification service
    await NotificationService.initialize();
    debugPrint('Notification service initialized');
    
    // Initialize background service (only on mobile platforms)
    if (!kIsWeb) {
      try {
        await BackgroundService.initialize();
        debugPrint('Background service initialized');
        
        // Start background service if there's an active alarm
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('alarm_settings')) {
          await BackgroundService.start();
          debugPrint('Background service started');
        }
      } catch (e) {
        debugPrint('Error initializing background service: $e');
        // Don't let background service errors prevent app startup
      }
    }
    debugPrint('Services initialization completed');
  } catch (e) {
    debugPrint('Error initializing services: $e');
    // Don't let service initialization errors prevent app startup
  }
}

class TrafficAlarmApp extends StatelessWidget {
  const TrafficAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
