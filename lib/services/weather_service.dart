import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1';

  /// Get current weather data for a location using Open-Meteo API
  Future<WeatherData> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Open-Meteo current weather endpoint
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,precipitation,visibility&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseOpenMeteoData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockWeatherData();
    }
  }

  /// Get weather data by city name using Open-Meteo geocoding
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      // First, get coordinates for the city using Open-Meteo geocoding
      final geocodeUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json',
      );

      final geocodeResponse = await http.get(geocodeUrl);
      if (geocodeResponse.statusCode != 200) {
        throw Exception('Failed to geocode city: ${geocodeResponse.statusCode}');
      }

      final geocodeData = jsonDecode(geocodeResponse.body);
      final results = geocodeData['results'] as List?;
      
      if (results == null || results.isEmpty) {
        throw Exception('City not found: $cityName');
      }

      final firstResult = results[0];
      final latitude = firstResult['latitude'];
      final longitude = firstResult['longitude'];

      // Now get weather for these coordinates
      return getCurrentWeather(latitude: latitude, longitude: longitude);
    } catch (e) {
      // Return mock data if API fails
      return _getMockWeatherData();
    }
  }

  /// Parse Open-Meteo weather response
  WeatherData _parseOpenMeteoData(Map<String, dynamic> data) {
    final current = data['current'];
    
    // Get weather code and convert to condition
    final weatherCode = current['weather_code'];
    final condition = _getConditionFromWeatherCode(weatherCode);
    
    // Extract current weather values
    final temperature = current['temperature_2m']?.toDouble() ?? 20.0;
    final humidity = current['relative_humidity_2m']?.toDouble() ?? 60.0;
    final windSpeed = current['wind_speed_10m']?.toDouble() ?? 5.0;
    final precipitation = current['precipitation']?.toDouble() ?? 0.0;
    final visibility = current['visibility']?.toDouble() ?? 10000.0; // in meters
    
    return WeatherData(
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      description: _getDescriptionFromWeatherCode(weatherCode),
      timestamp: DateTime.now(),
      visibility: visibility / 1000.0, // Convert to km
      precipitation: precipitation,
    );
  }

  /// Convert Open-Meteo weather code to condition string
  String _getConditionFromWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'Rain';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain';
      case 85:
      case 86:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Clear';
    }
  }

  /// Convert Open-Meteo weather code to description
  String _getDescriptionFromWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'clear sky';
      case 1:
        return 'mainly clear';
      case 2:
        return 'partly cloudy';
      case 3:
        return 'overcast';
      case 45:
        return 'fog';
      case 48:
        return 'depositing rime fog';
      case 51:
        return 'light drizzle';
      case 53:
        return 'moderate drizzle';
      case 55:
        return 'dense drizzle';
      case 56:
        return 'light freezing drizzle';
      case 57:
        return 'dense freezing drizzle';
      case 61:
        return 'slight rain';
      case 63:
        return 'moderate rain';
      case 65:
        return 'heavy rain';
      case 66:
        return 'light freezing rain';
      case 67:
        return 'heavy freezing rain';
      case 71:
        return 'slight snow fall';
      case 73:
        return 'moderate snow fall';
      case 75:
        return 'heavy snow fall';
      case 77:
        return 'snow grains';
      case 80:
        return 'slight rain showers';
      case 81:
        return 'moderate rain showers';
      case 82:
        return 'violent rain showers';
      case 85:
        return 'slight snow showers';
      case 86:
        return 'heavy snow showers';
      case 95:
        return 'thunderstorm';
      case 96:
        return 'thunderstorm with slight hail';
      case 99:
        return 'thunderstorm with heavy hail';
      default:
        return 'clear sky';
    }
  }

  /// Mock weather data for testing when API is not available
  WeatherData _getMockWeatherData() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Simulate different weather based on time of day
    String condition;
    double precipitation = 0.0;
    
    if (hour >= 6 && hour <= 8) {
      // Morning - often foggy or rainy
      condition = 'Fog';
      precipitation = 2.0;
    } else if (hour >= 9 && hour <= 17) {
      // Daytime - usually clear or partly cloudy
      condition = 'Clear';
    } else if (hour >= 18 && hour <= 20) {
      // Evening - might be cloudy
      condition = 'Cloudy';
    } else {
      // Night - clear
      condition = 'Clear';
    }

    return WeatherData(
      condition: condition,
      temperature: 20.0 + (hour - 12).abs() * 2.0, // Simulate temperature variation
      humidity: 60.0 + (hour % 3) * 10.0,
      windSpeed: 5.0 + (hour % 2) * 3.0,
      description: condition.toLowerCase(),
      timestamp: now,
      visibility: condition == 'Fog' ? 0.5 : 10.0,
      precipitation: precipitation,
    );
  }

  /// Get weather-based travel delay in minutes
  int getWeatherDelay(WeatherData weather) {
    if (!weather.hasSignificantWeatherImpact) return 0;
    
    // Calculate delay based on weather conditions
    const baseDelay = 5; // 5 minutes base delay
    final multiplier = weather.weatherDelayMultiplier;
    
    return (baseDelay * multiplier).round();
  }

  /// Get weather warning message for display
  String getWeatherWarning(WeatherData weather) {
    if (!weather.hasSignificantWeatherImpact) return '';
    
    if (weather.condition.toLowerCase().contains('snow')) {
      return '❄️ Snow conditions - Drive carefully!';
    } else if (weather.condition.toLowerCase().contains('rain') && weather.precipitation > 10.0) {
      return '🌧️ Heavy rain - Reduced visibility!';
    } else if (weather.condition.toLowerCase().contains('fog')) {
      return '🌫️ Foggy conditions - Low visibility!';
    } else if (weather.windSpeed > 30.0) {
      return '💨 High winds - Drive with caution!';
    }
    
    return '⚠️ Weather conditions may affect travel time';
  }
}
