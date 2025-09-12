import 'dart:math';
import '../models/traffic_data.dart';

class TrafficService {
  static const String _currentLocation = "Current Location"; // Placeholder for user's location
  
  /// Fetches traffic data for a route. Currently uses dummy data.
  /// In production, this would call Google Maps Directions API.
  Future<TrafficData> getTrafficData(String destination) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate dummy traffic data based on time of day and randomness
    final now = DateTime.now();
    final hour = now.hour;
    
    // Base travel time (without traffic)
    int baseDuration = _getBaseDuration(destination);
    
    // Traffic multiplier based on time of day
    double trafficMultiplier = _getTrafficMultiplier(hour);
    
    // Add some randomness to simulate real traffic conditions
    final random = Random();
    trafficMultiplier += (random.nextDouble() - 0.5) * 0.4; // ±20% variation
    trafficMultiplier = trafficMultiplier.clamp(1.0, 3.0);
    
    int durationInTraffic = (baseDuration * trafficMultiplier).round();
    
    String trafficCondition = _getTrafficCondition(trafficMultiplier);
    
    return TrafficData(
      origin: _currentLocation,
      destination: destination,
      durationInMinutes: baseDuration,
      durationInTrafficMinutes: durationInTraffic,
      trafficCondition: trafficCondition,
      timestamp: now,
    );
  }
  
  /// Get base travel duration based on destination (dummy implementation)
  int _getBaseDuration(String destination) {
    // Simple hash-based duration for consistent results
    int hash = destination.hashCode.abs();
    return 15 + (hash % 60); // 15-75 minutes base duration
  }
  
  /// Get traffic multiplier based on hour of day
  double _getTrafficMultiplier(int hour) {
    if (hour >= 7 && hour <= 9) {
      // Morning rush hour
      return 1.8;
    } else if (hour >= 17 && hour <= 19) {
      // Evening rush hour
      return 2.0;
    } else if (hour >= 12 && hour <= 14) {
      // Lunch time
      return 1.3;
    } else if (hour >= 22 || hour <= 5) {
      // Late night/early morning
      return 1.0;
    } else {
      // Regular hours
      return 1.2;
    }
  }
  
  /// Determine traffic condition based on multiplier
  String _getTrafficCondition(double multiplier) {
    if (multiplier <= 1.2) {
      return 'light';
    } else if (multiplier <= 1.6) {
      return 'moderate';
    } else {
      return 'heavy';
    }
  }
  
  /// Calculate optimal alarm time based on traffic data
  DateTime calculateAlarmTime({
    required DateTime arrivalTime,
    required int bufferMinutes,
    required TrafficData trafficData,
  }) {
    // Total time needed = travel time + buffer time
    int totalMinutesNeeded = trafficData.durationInTrafficMinutes + bufferMinutes;
    
    // Calculate alarm time by subtracting total time from arrival time
    DateTime alarmTime = arrivalTime.subtract(Duration(minutes: totalMinutesNeeded));
    
    return alarmTime;
  }
  
  /// Check if alarm time needs adjustment based on new traffic data
  bool shouldAdjustAlarm({
    required DateTime currentAlarmTime,
    required DateTime arrivalTime,
    required int bufferMinutes,
    required TrafficData newTrafficData,
  }) {
    DateTime newAlarmTime = calculateAlarmTime(
      arrivalTime: arrivalTime,
      bufferMinutes: bufferMinutes,
      trafficData: newTrafficData,
    );
    
    // Adjust if new alarm time is more than 5 minutes earlier than current
    return newAlarmTime.isBefore(currentAlarmTime.subtract(const Duration(minutes: 5)));
  }
}
