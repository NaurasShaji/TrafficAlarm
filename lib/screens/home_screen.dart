import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm_settings.dart';
import '../services/alarm_manager.dart';
import 'alarm_setup_screen.dart';
import 'alarm_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlarmManager _alarmManager = AlarmManager();
  StreamSubscription<AlarmSettings?>? _alarmSubscription;
  AlarmSettings? _currentAlarm;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('HomeScreen: Starting initialization');
      await _alarmManager.initialize();
      debugPrint('HomeScreen: AlarmManager initialized');
      
      _alarmSubscription = _alarmManager.alarmStream.listen((alarm) {
        debugPrint('HomeScreen: Received alarm update: ${alarm?.isActive}');
        if (mounted) {
          setState(() {
            _currentAlarm = alarm;
            _isLoading = false;
          });
        }
      });
      
      // Ensure loading state is cleared even if no alarm is set
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isLoading) {
          debugPrint('HomeScreen: Timeout reached, clearing loading state');
          setState(() {
            _isLoading = false;
          });
        }
      });
      
    } catch (e) {
      debugPrint('HomeScreen: Error during initialization: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Alarm'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentAlarm != null && _currentAlarm!.isActive) {
      return AlarmDisplayScreen(
        alarm: _currentAlarm!,
        onCancelAlarm: _cancelAlarm,
      );
    } else {
      return _buildNoAlarmView();
    }
  }

  Widget _buildNoAlarmView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.alarm_add,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Alarm',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Set up a traffic-aware alarm to ensure you arrive on time, even with changing traffic conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToSetup,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Set Smart Alarm'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSetup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AlarmSetupScreen(),
      ),
    );

    if (result == true && mounted) {
      // Alarm was set successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm set successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancelAlarm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Alarm'),
        content: const Text('Are you sure you want to cancel this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _alarmManager.cancelAlarm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm cancelled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
