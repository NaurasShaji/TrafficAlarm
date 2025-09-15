import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/route_data.dart';
import '../config/api_config.dart';

class GoogleMapsService {
  static String get _apiKey => ApiConfig.googleMapsApiKey;
  static const String _directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String _geocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

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

  /// Get route data between two points
  Future<RouteData> getRoute({
    required String origin,
    required String destination,
    String travelMode = 'driving',
  }) async {
    // Check if API is configured
    if (!ApiConfig.isGoogleMapsConfigured) {
      print('Google Maps API key not configured, using mock data');
      return _getMockRouteData(origin, destination);
    }

    try {
      final originCoords = await _getCoordinates(origin);
      final destCoords = await _getCoordinates(destination);

      final url = Uri.parse(
        '$_directionsUrl?origin=${originCoords.latitude},${originCoords.longitude}'
        '&destination=${destCoords.latitude},${destCoords.longitude}'
        '&mode=$travelMode'
        '&departure_time=now'
        '&traffic_model=best_guess'
        '&key=$_apiKey',
      );

      print('Making Google Maps API request to: ${url.toString().replaceAll(_apiKey, 'API_KEY_HIDDEN')}');
      
      final response = await http.get(url);
      print('Google Maps API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          print('Successfully retrieved route data from Google Maps API');
          return _parseRouteData(data, origin, destination);
        } else {
          print('Google Maps API error: ${data['status']} - ${data['error_message'] ?? 'No routes found'}');
          throw Exception('Google Maps API error: ${data['status']}');
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

  /// Get coordinates for an address
  Future<Position> _getCoordinates(String address) async {
    try {
      if (address.toLowerCase() == 'current location') {
        return await getCurrentLocation();
      }

      // Check if API is configured
      if (!ApiConfig.isGoogleMapsConfigured) {
        print('Google Maps API key not configured for geocoding, using mock coordinates');
        return _getMockCoordinates(address);
      }

      final url = Uri.parse(
        '$_geocodingUrl?address=${Uri.encodeComponent(address)}&key=$_apiKey',
      );

      print('Making geocoding request for: $address');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          print('Successfully geocoded address: $address');
          return Position(
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
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
          print('Geocoding error: ${data['status']} - ${data['error_message'] ?? 'Address not found'}');
          throw Exception('Address not found: ${data['status']}');
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

  RouteData _parseRouteData(Map<String, dynamic> data, String origin, String destination) {
    if (data['routes'].isEmpty) {
      throw Exception('No routes found');
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    
    // Extract duration and distance
    final duration = leg['duration']['value'] ~/ 60; // Convert to minutes
    final durationInTraffic = leg['duration_in_traffic']?['value'] ~/ 60 ?? duration;
    final distance = leg['distance']['value'] / 1000.0; // Convert to km
    final polyline = route['overview_polyline']['points'];

    print('Route data - Duration: ${duration}min, Duration in traffic: ${durationInTraffic}min, Distance: ${distance.toStringAsFixed(1)}km');

    // Parse steps
    final steps = <RouteStep>[];
    for (var step in leg['steps']) {
      steps.add(RouteStep(
        instruction: _cleanInstruction(step['html_instructions']),
        durationInMinutes: step['duration']['value'] ~/ 60,
        distanceInKm: step['distance']['value'] / 1000.0,
        maneuver: step['maneuver'] ?? '',
        polyline: step['polyline']['points'],
      ));
    }

    // Determine traffic condition based on actual vs traffic duration
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
      origin: leg['start_address'] ?? origin,
      destination: leg['end_address'] ?? destination,
      durationInMinutes: duration,
      durationInTrafficMinutes: durationInTraffic,
      trafficCondition: trafficCondition,
      steps: steps,
      polyline: polyline,
      distanceInKm: distance,
      timestamp: DateTime.now(),
      summary: route['summary'] ?? 'Route to $destination',
    );
  }

  String _cleanInstruction(String htmlInstruction) {
    // Remove HTML tags from instruction
    return htmlInstruction
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
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
    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDestination = Uri.encodeComponent(destination);
    
    // Try to get actual coordinates for better ride booking integration
    try {
      final originCoords = await _getCoordinates(origin);
      final destCoords = await _getCoordinates(destination);
      
      return {
        'Uber': 'https://m.uber.com/ul/?action=setPickup&pickup[latitude]=${originCoords.latitude}&pickup[longitude]=${originCoords.longitude}&dropoff[latitude]=${destCoords.latitude}&dropoff[longitude]=${destCoords.longitude}',
        'Lyft': 'https://lyft.com/ride?id=lyft&pickup[latitude]=${originCoords.latitude}&pickup[longitude]=${originCoords.longitude}&destination[latitude]=${destCoords.latitude}&destination[longitude]=${destCoords.longitude}',
        'Google Maps': 'https://www.google.com/maps/dir/$encodedOrigin/$encodedDestination',
      };
    } catch (e) {
      // Fallback to address-based URLs
      return {
        'Uber': 'https://m.uber.com/ul/?action=setPickup&pickup=my%20location&dropoff=$encodedDestination',
        'Lyft': 'https://lyft.com/ride?destination=$encodedDestination',
        'Google Maps': 'https://www.google.com/maps/dir/$encodedOrigin/$encodedDestination',
      };
    }
  }
}
