# 🚦 Traffic Alarm Clock App

A smart alarm clock that wakes you up earlier or later depending on live traffic conditions for your daily commute. This Flutter app combines real-time traffic data, weather information, news updates, and music to create the ultimate morning experience.

## 🌟 Features

### 🚗 Traffic-Aware Alarms
- **Smart Timing**: If your route has heavy traffic, the alarm rings earlier
- **Clear Roads**: If roads are clear, it lets you sleep a bit longer
- **Real-time Updates**: Continuously monitors traffic conditions and adjusts alarm time

### 🗺️ Smart Route Suggestions
- **Best Route + ETA**: Shows the optimal route and estimated arrival time after alarm
- **Traffic Visualization**: Color-coded traffic conditions (🟢 Light, 🟡 Moderate, 🔴 Heavy)
- **Step-by-step Directions**: Detailed turn-by-turn navigation

### 🚕 Instant Ride Booking
- **Multiple Services**: Integration with Uber, Lyft, and Google Maps
- **One-tap Booking**: Book rides directly from the app
- **Price Comparison**: Compare different ride services

### 🌤️ Weather + Traffic Combo
- **Weather Integration**: Considers rain, snow, fog, and wind conditions
- **Smart Adjustments**: Alarm adjusts for slower driving in bad weather
- **Weather Warnings**: Alerts about conditions that may affect travel

### 📰 Personalized Morning Experience
- **News Headlines**: Get morning news briefing after alarm
- **Morning Music**: Spotify integration for wake-up playlists
- **Smart Reminders**: "Leave in 20 mins or you'll be late" notifications

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- API Keys for external services (see Configuration section)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/traffic-alarm-app.git
   cd traffic-alarm-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys** (see Configuration section below)

4. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Required API Keys

The app requires several API keys to function properly. Edit `lib/config/api_config.dart` and replace the placeholder values:

#### 1. Google Maps API
- **Purpose**: Traffic data, route calculation, geocoding
- **Get Key**: [Google Cloud Console](https://console.cloud.google.com/)
- **Required APIs**: Directions API, Geocoding API, Maps JavaScript API
- **Cost**: Free tier available (200 requests/day)

```dart
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

#### 2. OpenWeather API
- **Purpose**: Weather data for travel adjustments
- **Get Key**: [OpenWeatherMap](https://openweathermap.org/api)
- **Cost**: Free tier available (1000 calls/day)

```dart
static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
```

#### 3. News API
- **Purpose**: Morning news headlines
- **Get Key**: [NewsAPI](https://newsapi.org/)
- **Cost**: Free tier available (1000 requests/day)

```dart
static const String newsApiKey = 'YOUR_NEWS_API_KEY';
```

#### 4. Spotify API (Optional)
- **Purpose**: Morning music playlists
- **Get Key**: [Spotify Developer](https://developer.spotify.com/)
- **Cost**: Free

```dart
static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
```

### Configuration File

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace these with your actual API keys
  static const String googleMapsApiKey = 'your_actual_google_maps_key';
  static const String openWeatherApiKey = 'your_actual_openweather_key';
  static const String newsApiKey = 'your_actual_news_key';
  static const String spotifyClientId = 'your_actual_spotify_client_id';
  static const String spotifyClientSecret = 'your_actual_spotify_client_secret';
  
  // Feature flags
  static const bool enableGoogleMaps = true;
  static const bool enableWeather = true;
  static const bool enableNews = true;
  static const bool enableSpotify = true;
  
  // Use mock data if APIs are not configured
  static const bool useMockData = false;
}
```

## 📱 Usage

### Setting Up an Alarm

1. **Open the app** and tap "Set Smart Alarm"
2. **Enter destination** (address, landmark, or business name)
3. **Set arrival time** when you need to reach your destination
4. **Adjust buffer time** (5-120 minutes) for extra safety margin
5. **Tap "Set Smart Alarm"** - the app will calculate the optimal wake-up time

### Smart Features

#### Traffic Monitoring
- The app continuously monitors traffic conditions
- If traffic gets worse, your alarm will ring earlier
- If traffic improves, you get extra sleep time

#### Weather Integration
- Considers current weather conditions
- Adjusts for rain, snow, fog, and high winds
- Shows weather warnings and recommendations

#### Morning Experience
- **News**: Tap news headlines to read full articles
- **Music**: Tap playlists to open in Spotify
- **Rides**: Book Uber, Lyft, or open in Google Maps
- **Routes**: View detailed turn-by-turn directions

## 🏗️ Architecture

### Project Structure
```
lib/
├── config/
│   └── api_config.dart          # API configuration
├── models/
│   ├── alarm_settings.dart      # Alarm data model
│   ├── traffic_data.dart        # Traffic data model
│   ├── weather_data.dart        # Weather data model
│   └── route_data.dart          # Route data model
├── screens/
│   ├── home_screen.dart         # Main screen
│   ├── alarm_setup_screen.dart  # Alarm configuration
│   └── alarm_display_screen.dart # Active alarm display
├── services/
│   ├── alarm_manager.dart       # Alarm management
│   ├── traffic_service.dart     # Traffic data service
│   ├── weather_service.dart     # Weather data service
│   ├── news_service.dart        # News service
│   ├── spotify_service.dart     # Music service
│   ├── google_maps_service.dart # Maps integration
│   └── notification_service.dart # Local notifications
└── main.dart                    # App entry point
```

### Key Components

#### Services
- **TrafficService**: Integrates Google Maps API for real-time traffic
- **WeatherService**: Fetches weather data from OpenWeather API
- **NewsService**: Provides morning news headlines
- **SpotifyService**: Manages music playlists and playback
- **AlarmManager**: Handles alarm scheduling and updates

#### Models
- **AlarmSettings**: Stores alarm configuration and state
- **TrafficData**: Represents traffic conditions and travel times
- **WeatherData**: Contains weather information and impact analysis
- **RouteData**: Detailed route information with turn-by-turn directions

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Debugging
- Check console logs for API errors
- Use mock data mode for testing without API keys
- Verify API key configuration in `api_config.dart`

## 🚨 Troubleshooting

### Common Issues

#### 1. API Key Errors
- **Problem**: "API key not configured" errors
- **Solution**: Check `lib/config/api_config.dart` and ensure all required keys are set

#### 2. Location Permissions
- **Problem**: App can't access location
- **Solution**: Grant location permissions in device settings

#### 3. Notification Issues
- **Problem**: Alarms not ringing
- **Solution**: Check notification permissions and battery optimization settings

#### 4. Mock Data Mode
- **Problem**: App shows mock data instead of real data
- **Solution**: Configure API keys and set `useMockData = false`

### Debug Mode
Enable debug logging by setting:
```dart
static const bool useMockData = true; // Use mock data for testing
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Maps API** for traffic and routing data
- **OpenWeather API** for weather information
- **NewsAPI** for news headlines
- **Spotify API** for music integration
- **Flutter** for the amazing framework

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search existing [Issues](https://github.com/yourusername/traffic-alarm-app/issues)
3. Create a new issue with detailed information

## 🔮 Future Features

- [ ] Calendar integration for meeting reminders
- [ ] Multiple alarm support
- [ ] Custom wake-up sounds
- [ ] Sleep tracking integration
- [ ] Voice commands
- [ ] Apple Watch support
- [ ] Smart home integration

---

**Made with ❤️ for better mornings and stress-free commutes!**