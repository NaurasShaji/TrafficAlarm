import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/alarm_manager.dart';

class AlarmSetupScreen extends StatefulWidget {
  const AlarmSetupScreen({super.key});

  @override
  State<AlarmSetupScreen> createState() => _AlarmSetupScreenState();
}

class _AlarmSetupScreenState extends State<AlarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 1));
  int _bufferMinutes = 15;
  bool _isLoading = false;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Smart Alarm'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Where do you need to go?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                hintText: 'Enter destination address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a destination';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'What time do you need to arrive?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Arrival Time'),
              subtitle: Text(
                DateFormat('h:mm a, EEE, MMM d').format(_arrivalTime),
                style: const TextStyle(fontSize: 16),
              ),
              onTap: _selectArrivalTime,
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!), 
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Buffer Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_bufferMinutes minutes',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _bufferMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_bufferMinutes minutes',
              onChanged: (value) {
                setState(() {
                  _bufferMinutes = value.round();
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _setAlarm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Set Smart Alarm'),
            ),
            const SizedBox(height: 16),
            Text(
              'The app will monitor traffic conditions and wake you up at the optimal time to ensure you arrive on schedule.',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectArrivalTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_arrivalTime),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      var newDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // If the selected time is in the past, set it for tomorrow
      if (newDateTime.isBefore(now)) {
        newDateTime = newDateTime.add(const Duration(days: 1));
      }

      setState(() {
        _arrivalTime = newDateTime;
      });
    }
  }

  Future<void> _setAlarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final alarmManager = AlarmManager();
      await alarmManager.initialize();
      
      await alarmManager.setAlarm(
        destination: _destinationController.text,
        arrivalTime: _arrivalTime,
        bufferMinutes: _bufferMinutes,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
