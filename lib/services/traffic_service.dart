import 'dart:math';
import '../models/traffic_data.dart';
import '../models/route_data.dart';
import '../models/weather_data.dart';
import 'osrm_service.dart';
import 'weather_service.dart';

class TrafficService {
  static const String _currentLocation = "Current Location";
  final OSRMService _osrmService = OSRMService();
  final WeatherService _weatherService = WeatherService();
  
  /// Fetches comprehensive traffic and route data for a destination
  Future<RouteData> getRouteData(String destination) async {
    try {
      // Get route data from OSRM
      final routeData = await _osrmService.getRoute(
        origin: _currentLocation,
        destination: destination,
      );
      
      return routeData;
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockRouteData(destination);
    }
  }
  
  /// Fetches traffic data for a route with weather integration
  Future<TrafficData> getTrafficData(String destination) async {
    try {
      // Get route data
      final routeData = await getRouteData(destination);
      
      // Get current location for weather
      final currentLocation = await _osrmService.getCurrentLocation();
      
      // Get weather data
      final weatherData = await _weatherService.getCurrentWeather(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      
      // Apply weather delay
      final weatherDelay = _weatherService.getWeatherDelay(weatherData);
      final adjustedDuration = routeData.durationInTrafficMinutes + weatherDelay;
      
      return TrafficData(
        origin: routeData.origin,
        destination: routeData.destination,
        durationInMinutes: routeData.durationInMinutes,
        durationInTrafficMinutes: adjustedDuration,
        trafficCondition: _getCombinedTrafficCondition(
          routeData.trafficCondition,
          weatherData,
        ),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback to mock data
      return _getMockTrafficData(destination);
    }
  }
  
  /// Get combined traffic condition considering both traffic and weather
  String _getCombinedTrafficCondition(String trafficCondition, WeatherData weather) {
    if (weather.hasSignificantWeatherImpact) {
      if (weather.condition.toLowerCase().contains('snow')) {
        return 'severe';
      } else if (weather.condition.toLowerCase().contains('rain') && weather.precipitation > 10.0) {
        return 'heavy';
      } else if (weather.condition.toLowerCase().contains('fog')) {
        return 'heavy';
      }
    }
    
    return trafficCondition;
  }
  
  /// Mock route data for fallback
  RouteData _getMockRouteData(String destination) {
    final now = DateTime.now();
    final hour = now.hour;
    
    int baseDuration = _getBaseDuration(destination);
    double trafficMultiplier = _getTrafficMultiplier(hour);
    
    final random = Random();
    trafficMultiplier += (random.nextDouble() - 0.5) * 0.4;
    trafficMultiplier = trafficMultiplier.clamp(1.0, 3.0);
    
    int durationInTraffic = (baseDuration * trafficMultiplier).round();
    String trafficCondition = _getTrafficCondition(trafficMultiplier);
    
    return RouteData(
      origin: _currentLocation,
      destination: destination,
      durationInMinutes: baseDuration,
      durationInTrafficMinutes: durationInTraffic,
      trafficCondition: trafficCondition,
      steps: [
        RouteStep(
          instruction: 'Head north on Main St',
          durationInMinutes: baseDuration ~/ 3,
          distanceInKm: 5.0,
          maneuver: 'straight',
          polyline: 'mock_polyline_1',
        ),
        RouteStep(
          instruction: 'Turn right onto Highway 101',
          durationInMinutes: baseDuration ~/ 3,
          distanceInKm: 10.0,
          maneuver: 'turn-right',
          polyline: 'mock_polyline_2',
        ),
        RouteStep(
          instruction: 'Arrive at destination',
          durationInMinutes: baseDuration ~/ 3,
          distanceInKm: 5.0,
          maneuver: 'arrive',
          polyline: 'mock_polyline_3',
        ),
      ],
      polyline: 'mock_overview_polyline',
      distanceInKm: 20.0,
      timestamp: now,
      summary: 'Route to $destination',
    );
  }
  
  /// Mock traffic data for fallback
  TrafficData _getMockTrafficData(String destination) {
    final now = DateTime.now();
    final hour = now.hour;
    
    int baseDuration = _getBaseDuration(destination);
    double trafficMultiplier = _getTrafficMultiplier(hour);
    
    final random = Random();
    trafficMultiplier += (random.nextDouble() - 0.5) * 0.4;
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
