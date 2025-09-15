class WeatherData {
  final String condition;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String description;
  final DateTime timestamp;
  final double visibility;
  final double precipitation;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.timestamp,
    required this.visibility,
    required this.precipitation,
  });

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'visibility': visibility,
      'precipitation': precipitation,
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      condition: json['condition'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      windSpeed: json['windSpeed'].toDouble(),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      visibility: json['visibility'].toDouble(),
      precipitation: json['precipitation'].toDouble(),
    );
  }

  /// Check if weather conditions will significantly impact driving
  bool get hasSignificantWeatherImpact {
    // Heavy rain, snow, fog, or high winds
    return condition.toLowerCase().contains('rain') && precipitation > 5.0 ||
           condition.toLowerCase().contains('drizzle') && precipitation > 3.0 ||
           condition.toLowerCase().contains('snow') ||
           condition.toLowerCase().contains('fog') ||
           condition.toLowerCase().contains('mist') ||
           windSpeed > 20.0 ||
           visibility < 1.0;
  }

  /// Get weather delay multiplier for travel time
  double get weatherDelayMultiplier {
    if (hasSignificantWeatherImpact) {
      if (condition.toLowerCase().contains('snow')) return 1.5;
      if (condition.toLowerCase().contains('rain') && precipitation > 10.0) return 1.3;
      if (condition.toLowerCase().contains('fog') || visibility < 0.5) return 1.4;
      if (windSpeed > 30.0) return 1.2;
    }
    return 1.0;
  }

  /// Get weather emoji for display
  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'partly cloudy':
        return '☁️';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'snowy':
      case 'snow':
        return '❄️';
      case 'foggy':
      case 'fog':
        return '🌫️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      default:
        return '🌤️';
    }
  }
}
