class ApiConfig {
  // Note: Google Maps has been replaced with OpenStreetMap + OSRM
  // No API key required for OSRM demo server, but for production use,
  // consider hosting your own OSRM instance
  
  // Open-Meteo Weather API (Free, no API key required)
  // Using Open-Meteo instead of OpenWeather for reliable, free weather data
  
  // News API
  static const String newsApiKey = 'YOUR_NEWS_API_KEY';
  
  // Spotify API
  static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
  
  // Google Calendar API (optional)
  static const String googleCalendarClientId = 'YOUR_GOOGLE_CALENDAR_CLIENT_ID';
  static const String googleCalendarClientSecret = 'YOUR_GOOGLE_CALENDAR_CLIENT_SECRET';
  
  // API URLs
  static const String osrmBaseUrl = 'https://router.project-osrm.org';
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/api/token';
  
  // Feature flags
  static const bool enableOSRM = true; // Free routing via OpenStreetMap
  static const bool enableWeather = true; // Free weather via Open-Meteo
  static const bool enableNews = true;
  static const bool enableSpotify = true;
  static const bool enableCalendar = false; // Set to true when implementing calendar features
  
  // Mock data fallback
  static const bool useMockData = false; // Set to true to use mock data instead of APIs
  
  // Validation
  static bool get isWeatherConfigured => enableWeather; // Open-Meteo is always available
  
  static bool get isNewsConfigured => 
      newsApiKey != 'YOUR_NEWS_API_KEY' && newsApiKey.isNotEmpty;
  
  static bool get isSpotifyConfigured => 
      spotifyClientId != 'YOUR_SPOTIFY_CLIENT_ID' && 
      spotifyClientId.isNotEmpty &&
      spotifyClientSecret != 'YOUR_SPOTIFY_CLIENT_SECRET' &&
      spotifyClientSecret.isNotEmpty;
  
  static bool get isCalendarConfigured => 
      googleCalendarClientId != 'YOUR_GOOGLE_CALENDAR_CLIENT_ID' && 
      googleCalendarClientId.isNotEmpty &&
      googleCalendarClientSecret != 'YOUR_GOOGLE_CALENDAR_CLIENT_SECRET' &&
      googleCalendarClientSecret.isNotEmpty;
  
  // Get configuration status
  static Map<String, bool> get configurationStatus => {
    'OSRM Routing': enableOSRM, // Always true for free OSRM service
    'Open-Meteo Weather': isWeatherConfigured, // Always true for free Open-Meteo
    'News API': isNewsConfigured,
    'Spotify': isSpotifyConfigured,
    'Google Calendar': isCalendarConfigured,
  };
  
  // Get missing configurations
  static List<String> get missingConfigurations {
    final status = configurationStatus;
    return status.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  // Helper method to check if using real data
  static bool get isUsingRealOSRMData => 
      enableOSRM && !useMockData;
  
  static bool get isUsingRealWeatherData => 
      enableWeather && !useMockData;
  
  // Get setup instructions for OSRM
  static String get osrmSetupInstructions => '''
OSRM (Open Source Routing Machine) Integration:

✅ Current Setup: Using free OSRM demo server
- No API key required
- Real routing data from OpenStreetMap
- Traffic simulation based on time of day

For Production Use:
1. Host your own OSRM instance for better reliability
2. Use Docker: docker run -p 5000:5000 osrm/osrm-backend
3. Update osrmBaseUrl in api_config.dart to your instance
4. Consider rate limiting and caching for high traffic

Benefits over Google Maps:
- Free and open source
- No API quotas or billing
- Privacy-friendly
- Community-driven data updates

Note: Real-time traffic data requires additional setup with traffic-aware OSRM profiles.
''';

  // Get setup instructions for Open-Meteo
  static String get openMeteoSetupInstructions => '''
Open-Meteo Weather API Integration:

✅ Current Setup: Using free Open-Meteo API
- No API key required
- Real weather data from national weather services
- High-quality forecasts and current conditions
- 10,000 free API calls per day

Features Available:
- Current weather conditions
- Temperature, humidity, wind speed
- Precipitation and visibility
- Weather condition descriptions
- Hourly and daily forecasts

Benefits over OpenWeatherMap:
- Completely free (no API key needed)
- No rate limits for reasonable usage
- Data from official weather services
- Privacy-friendly (no tracking)
- Better forecast accuracy in many regions

API Documentation: https://open-meteo.com/en/docs
''';
}
