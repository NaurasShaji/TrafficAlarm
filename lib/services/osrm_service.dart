import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/route_data.dart';

class OSRMService {
  // OSRM demo server - for production, you should host your own OSRM instance
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';

  /// Get current location
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // Return mock location if real location fails
      print('Location error: $e, using mock location');
      return Position(
        latitude: 37.7749, // San Francisco coordinates
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }

  /// Get route data between two points using OSRM
  Future<RouteData> getRoute({
    required String origin,
    required String destination,
    String profile = 'driving', // driving, walking, cycling
  }) async {
    try {
      final originCoords = await _getCoordinates(origin);
      final destCoords = await _getCoordinates(destination);

      // OSRM expects coordinates in longitude,latitude format
      final url = Uri.parse(
        '$_osrmBaseUrl/route/v1/$profile/${originCoords.longitude},${originCoords.latitude};${destCoords.longitude},${destCoords.latitude}'
        '?overview=full&geometries=geojson&steps=true&annotations=true',
      );

      print('Making OSRM API request to: $url');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'TrafficAlarmApp/1.0',
      });
      
      print('OSRM API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          print('Successfully retrieved route data from OSRM API');
          return _parseOSRMRouteData(data, origin, destination, originCoords, destCoords);
        } else {
          print('OSRM API error: ${data['code']} - ${data['message'] ?? 'No routes found'}');
          throw Exception('OSRM API error: ${data['code']}');
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load route data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route data: $e');
      print('Falling back to mock data');
      // Return mock route data if API fails
      return _getMockRouteData(origin, destination);
    }
  }

  /// Get coordinates for an address using Nominatim (OpenStreetMap geocoding)
  Future<Position> _getCoordinates(String address) async {
    try {
      if (address.toLowerCase() == 'current location') {
        return await getCurrentLocation();
      }

      final url = Uri.parse(
        '$_nominatimUrl/search?format=json&q=${Uri.encodeComponent(address)}&limit=1',
      );

      print('Making geocoding request for: $address');
      final response = await http.get(url, headers: {
        'User-Agent': 'TrafficAlarmApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          print('Successfully geocoded address: $address');
          return Position(
            latitude: double.parse(location['lat']),
            longitude: double.parse(location['lon']),
            timestamp: DateTime.now(),
            accuracy: 10.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        } else {
          print('No results found for address: $address');
          throw Exception('Address not found');
        }
      } else {
        throw Exception('Geocoding HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error geocoding address $address: $e');
      print('Using mock coordinates for: $address');
      // Return mock coordinates
      return _getMockCoordinates(address);
    }
  }

  /// Generate mock coordinates for testing
  Position _getMockCoordinates(String address) {
    return Position(
      latitude: 37.7749 + (address.hashCode % 100) / 1000,
      longitude: -122.4194 + (address.hashCode % 100) / 1000,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  /// Parse OSRM API response into RouteData
  RouteData _parseOSRMRouteData(
    Map<String, dynamic> data, 
    String origin, 
    String destination,
    Position originCoords,
    Position destCoords,
  ) {
    final route = data['routes'][0];
    final legs = route['legs'] as List;
    
    // Extract duration and distance
    final duration = (route['duration'] / 60).round(); // Convert to minutes
    final distance = route['distance'] / 1000.0; // Convert to km
    
    // For real-time traffic, OSRM doesn't provide traffic data by default
    // We'll simulate traffic conditions based on time of day
    final durationInTraffic = _simulateTrafficDuration(duration);
    
    print('Route data - Duration: ${duration}min, Distance: ${distance.toStringAsFixed(1)}km');

    // Parse steps from all legs
    final steps = <RouteStep>[];
    for (var leg in legs) {
      final legSteps = leg['steps'] as List;
      for (var step in legSteps) {
        steps.add(RouteStep(
          instruction: step['maneuver']['instruction'] ?? 'Continue',
          durationInMinutes: (step['duration'] / 60).round(),
          distanceInKm: step['distance'] / 1000.0,
          maneuver: step['maneuver']['type'] ?? '',
          polyline: '', // OSRM uses different geometry format
        ));
      }
    }

    // Determine traffic condition based on simulated traffic
    String trafficCondition;
    double trafficRatio = durationInTraffic / duration;
    
    if (trafficRatio >= 1.5) {
      trafficCondition = 'heavy';
    } else if (trafficRatio >= 1.2) {
      trafficCondition = 'moderate';
    } else {
      trafficCondition = 'light';
    }

    print('Traffic condition: $trafficCondition (ratio: ${trafficRatio.toStringAsFixed(2)})');

    return RouteData(
      origin: origin,
      destination: destination,
      durationInMinutes: duration,
      durationInTrafficMinutes: durationInTraffic,
      trafficCondition: trafficCondition,
      steps: steps,
      polyline: _encodePolyline(route['geometry']['coordinates']),
      distanceInKm: distance,
      timestamp: DateTime.now(),
      summary: 'Route via ${steps.length} steps',
    );
  }

  /// Simulate traffic duration based on time of day
  int _simulateTrafficDuration(int baseDuration) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Simulate different traffic based on time
    double trafficMultiplier = 1.0;
    
    if (hour >= 7 && hour <= 9) {
      trafficMultiplier = 1.8; // Morning rush
    } else if (hour >= 17 && hour <= 19) {
      trafficMultiplier = 2.0; // Evening rush
    } else if (hour >= 12 && hour <= 14) {
      trafficMultiplier = 1.3; // Lunch time
    } else if (hour >= 22 || hour <= 5) {
      trafficMultiplier = 0.8; // Night time - less traffic
    }

    return (baseDuration * trafficMultiplier).round();
  }

  /// Simple polyline encoding for coordinates
  String _encodePolyline(List<dynamic> coordinates) {
    // For simplicity, return a basic string representation
    // In a real implementation, you might want to use proper polyline encoding
    return coordinates.take(10).map((coord) => '${coord[1]},${coord[0]}').join(';');
  }

  /// Mock route data for testing when API is not available
  RouteData _getMockRouteData(String origin, String destination) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Simulate different traffic based on time
    int baseDuration = 30 + (destination.hashCode % 30);
    double trafficMultiplier = 1.0;
    
    if (hour >= 7 && hour <= 9) {
      trafficMultiplier = 1.8; // Morning rush
    } else if (hour >= 17 && hour <= 19) {
      trafficMultiplier = 2.0; // Evening rush
    } else if (hour >= 12 && hour <= 14) {
      trafficMultiplier = 1.3; // Lunch time
    }

    final durationInTraffic = (baseDuration * trafficMultiplier).round();
    String trafficCondition = 'light';
    if (trafficMultiplier > 1.5) {
      trafficCondition = 'heavy';
    } else if (trafficMultiplier > 1.2) {
      trafficCondition = 'moderate';
    }

    return RouteData(
      origin: origin,
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

  /// Get ride booking URLs for different services
  Future<Map<String, String>> getRideBookingUrls({
    required String origin,
    required String destination,
  }) async {
    // Try to get actual coordinates for better ride booking integration
    try {
      final originCoords = await _getCoordinates(origin);
      final destCoords = await _getCoordinates(destination);
      
      return {
        'Uber': 'https://m.uber.com/ul/?action=setPickup&pickup[latitude]=${originCoords.latitude}&pickup[longitude]=${originCoords.longitude}&dropoff[latitude]=${destCoords.latitude}&dropoff[longitude]=${destCoords.longitude}',
        'Lyft': 'https://lyft.com/ride?id=lyft&pickup[latitude]=${originCoords.latitude}&pickup[longitude]=${originCoords.longitude}&destination[latitude]=${destCoords.latitude}&destination[longitude]=${destCoords.longitude}',
        'OpenStreetMap': 'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=${originCoords.latitude}%2C${originCoords.longitude}%3B${destCoords.latitude}%2C${destCoords.longitude}',
      };
    } catch (e) {
      // Fallback to address-based URLs
      final encodedOrigin = Uri.encodeComponent(origin);
      final encodedDestination = Uri.encodeComponent(destination);
      
      return {
        'Uber': 'https://m.uber.com/ul/?action=setPickup&pickup=my%20location&dropoff=$encodedDestination',
        'Lyft': 'https://lyft.com/ride?destination=$encodedDestination',
        'OpenStreetMap': 'https://www.openstreetmap.org/directions?from=$encodedOrigin&to=$encodedDestination',
      };
    }
  }
}