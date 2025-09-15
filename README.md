# 🚦 Traffic Alarm Clock App

A smart alarm clock that wakes you up at the optimal time based on real-time traffic conditions, weather, and your commute destination. This Flutter app uses **OpenStreetMap + OSRM** for free routing and **Open-Meteo** for weather data, providing an intelligent morning experience without expensive API costs.

## 🌟 Features

### 🚗 Traffic-Aware Smart Alarms
- **Intelligent Timing**: Automatically calculates when to wake up based on traffic conditions
- **Dual Alarm System**: Gentle wake-up 10 minutes before departure + urgent alarm at exact leave time
- **Real-time Adjustments**: Continuously monitors conditions and updates alarm times
- **Custom Audio**: Built-in alarm sounds with fallback to system alerts

### 🔊 Advanced Alarm System
- **Gentle Alarm**: Soft 30-second wake-up sound 10 minutes before departure
- **Urgent Alarm**: Loud 2-minute alarm at calculated leave time
- **Stop Controls**: Easy-to-access alarm stop button when sounds are playing
- **Background Notifications**: Alarms work even when app is closed
- **Visual Feedback**: Animated loading during alarm setup with rotating alarm icon

### �️ Free Routing with OpenStreetMap
- **OSRM Integration**: Uses free Open Source Routing Machine for navigation
- **Real Route Data**: Actual routing based on OpenStreetMap community data
- **Traffic Simulation**: Time-of-day based traffic calculations
- **Turn-by-turn Directions**: Detailed navigation instructions
- **Multiple Transport Options**: Driving, walking, cycling routes

### 🌤️ Weather-Aware Adjustments
- **Open-Meteo Integration**: Free weather API with high-quality forecasts
- **Impact Analysis**: Adjusts departure time for rain, snow, fog conditions
- **Weather Warnings**: Alerts about conditions affecting travel time
- **Real Weather Data**: From national weather services worldwide

### 📰 Morning Information Hub
- **News Headlines**: Optional morning news briefing
- **Spotify Integration**: Wake-up playlists and morning music
- **Ride Booking**: Direct links to Uber, Lyft, and other ride services
- **Smart Notifications**: "Time to leave!" alerts with destination info

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

### API Services Used

This app uses **free and open-source** services as the primary data sources:

#### ✅ **FREE SERVICES** (No API Keys Required)
- **🗺️ OSRM (Open Source Routing Machine)**: Free routing via OpenStreetMap
- **🌤️ Open-Meteo Weather API**: Free weather data from national weather services
- **📱 System Notifications**: Built-in alarm functionality

#### 🔐 **OPTIONAL PAID SERVICES** (API Keys Required)
Edit `lib/config/api_config.dart` to configure optional services:

**📰 News API** (Optional)
- Get morning news headlines
- Free tier: 1000 requests/day
- Get key: [NewsAPI.org](https://newsapi.org/)

**🎵 Spotify API** (Optional)  
- Morning music playlists
- Free developer account
- Get key: [Spotify Developer](https://developer.spotify.com/)

**📅 Google Calendar API** (Optional)
- Calendar integration for meetings
- Free tier available
- Get key: [Google Cloud Console](https://console.cloud.google.com/)

### Configuration Setup

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // News API (optional)
  static const String newsApiKey = 'YOUR_NEWS_API_KEY';
  
  // Spotify API (optional)
  static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
  
  // Google Calendar API (optional)
  static const String googleCalendarClientId = 'YOUR_GOOGLE_CALENDAR_CLIENT_ID';
  
  // Feature flags - enable/disable services
  static const bool enableOSRM = true; // Always free
  static const bool enableWeather = true; // Always free
  static const bool enableNews = true; // Requires API key
  static const bool enableSpotify = true; // Requires API key
  static const bool enableCalendar = false; // Requires API key
}
```

### 🆓 **Running Without API Keys**
The app works perfectly with just the free services:
- ✅ Smart alarms with traffic-aware timing
- ✅ Real routing and navigation 
- ✅ Weather-based adjustments
- ✅ Alarm sounds and notifications
- ✅ Basic morning information display

## 📱 Usage

### Setting Up Your First Smart Alarm

1. **📍 Enter Destination**
   - Open the app and tap "Set Smart Alarm"
   - Enter your destination (address, business name, or landmark)
   - The app uses OpenStreetMap for accurate location finding

2. **⏰ Set Arrival Time**
   - Choose when you need to arrive at your destination
   - The app will automatically calculate when to wake you up
   - Accounts for current traffic and weather conditions

3. **⚡ Adjust Buffer Time**
   - Set extra time (5-120 minutes) for safety margin
   - Recommended: 15-30 minutes for important meetings
   - More buffer = less stress, guaranteed on-time arrival

4. **✅ Activate Smart Alarm**
   - Tap "Set Smart Alarm" - watch the animated loading
   - App calculates optimal wake-up time using real traffic data
   - Alarm is now active and monitoring conditions

### 🔊 Alarm Experience

#### Gentle Wake-Up (10 minutes before)
- Soft alarm sound to start waking up
- "Get ready to leave" notification
- 30-second duration, gentle volume

#### Time to Leave! (Calculated departure time)
- Urgent alarm sound with vibration
- "🚨 TIME TO LEAVE!" display
- 2-minute duration, full volume
- LED lights and persistent notification

#### Smart Controls
- **Stop Button**: Appears when alarm is playing
- **Snooze Option**: Quick 5-minute delay
- **Cancel Alarm**: Turn off completely

### 🌤️ Weather & Traffic Intelligence

#### Automatic Adjustments
- **Heavy Traffic**: Alarm rings earlier automatically
- **Clear Roads**: You get extra sleep time
- **Bad Weather**: Additional time for slower driving
- **Real-time Updates**: Continuous monitoring until alarm time

#### Live Information Display
- **🚗 Route Info**: Distance, duration, traffic conditions
- **🌡️ Weather**: Current conditions and travel impact
- **📰 News**: Morning headlines (if configured)
- **🎵 Music**: Spotify playlists (if configured)

### 🚕 Transportation Options

#### Ride Booking Integration
- **Uber**: Direct booking link
- **Lyft**: Quick ride request
- **Google Maps**: Public transit options
- **Walking/Cycling**: Alternative route suggestions

#### Navigation
- **OpenStreetMap**: Free, community-driven maps
- **Turn-by-turn**: Detailed driving directions
- **Real-time**: Updated route information

## 🏗️ Architecture

### Project Structure
```
lib/
├── config/
│   └── api_config.dart           # API configuration & feature flags
├── models/
│   ├── alarm_settings.dart       # Alarm data model
│   ├── route_data.dart          # Route and traffic data model
│   ├── weather_data.dart        # Weather data model
│   └── news_article.dart        # News data model
├── screens/
│   ├── home_screen.dart         # Main screen with alarm status
│   ├── alarm_setup_screen.dart  # Alarm configuration with animation
│   └── alarm_display_screen.dart # Active alarm with live data
├── services/
│   ├── alarm_manager.dart       # Alarm scheduling & management
│   ├── alarm_sound_service.dart # Audio playback for alarms
│   ├── traffic_service.dart     # Traffic calculations
│   ├── weather_service.dart     # Open-Meteo weather integration
│   ├── osrm_service.dart        # OpenStreetMap routing
│   ├── news_service.dart        # News API integration
│   ├── spotify_service.dart     # Music service integration
│   └── notification_service.dart # System notifications
├── assets/
│   └── audio/                   # Alarm sound files
└── main.dart                    # App entry point
```

### Key Technologies

#### 🆓 **Free Services**
- **OSRM (OpenStreetMap)**: Community-driven routing and traffic simulation
- **Open-Meteo**: High-quality weather data from national weather services
- **Flutter Local Notifications**: System-level alarm notifications
- **AudioPlayers**: Custom alarm sound playback

#### 🔧 **Core Components**
- **AlarmManager**: Handles alarm scheduling with traffic/weather intelligence
- **AlarmSoundService**: Manages dual alarm system (gentle + urgent)
- **OSRMService**: Free routing using OpenStreetMap data
- **WeatherService**: Weather impact analysis for travel time
- **NotificationService**: Background alarm functionality

### Data Flow

1. **Setup**: User configures destination and arrival time
2. **Calculation**: OSRM calculates route, weather service checks conditions
3. **Scheduling**: System schedules two alarms (gentle + urgent)
4. **Monitoring**: Continuous traffic/weather monitoring until alarm time
5. **Activation**: Dual alarm system with audio + visual + notification alerts

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

#### 1. 🔑 API Configuration
- **Problem**: Optional features not working (news, music)
- **Solution**: Check `lib/config/api_config.dart` and add API keys for desired features
- **Note**: Core alarm functionality works without any API keys

#### 2. 📍 Location Services
- **Problem**: Can't find destinations or get current location
- **Solution**: Enable location permissions in device settings
- **Alternative**: Manually enter full addresses instead of "nearby" searches

#### 3. 🔔 Alarm Notifications
- **Problem**: Alarms not ringing or notifications not showing
- **Solutions**: 
  - Check notification permissions in device settings
  - Disable battery optimization for the app
  - Ensure "Do Not Disturb" allows alarms
  - Test with short-term alarms first

#### 4. 🎵 Audio Issues
- **Problem**: Alarm sounds not playing
- **Solutions**:
  - Check device volume settings
  - Verify audio permissions
  - Test with system alerts (fallback mode)
  - Restart app if audio service fails

#### 5. 🗺️ Routing Problems
- **Problem**: "Route not found" or incorrect directions
- **Solutions**:
  - Try alternative address formats
  - Check internet connection
  - Use full addresses instead of landmarks
  - Verify destination exists on OpenStreetMap

### Debug Features

#### Enable Debug Mode
Set in `lib/config/api_config.dart`:
```dart
static const bool useMockData = true; // Test with sample data
```

#### Check Service Status
The app displays configuration status:
- ✅ **OSRM Routing**: Always available (free)
- ✅ **Open-Meteo Weather**: Always available (free)  
- ❌ **News API**: Requires API key
- ❌ **Spotify**: Requires API key

### Performance Tips

#### Optimize Battery Usage
- Close other apps when testing alarms
- Ensure device doesn't enter deep sleep mode
- Use "Do not optimize" battery setting for the app

#### Network Connectivity
- Stable internet required for route calculation
- Offline mode not supported (requires live traffic data)
- WiFi recommended for initial setup

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **🗺️ OpenStreetMap Community** for free, comprehensive map data
- **🛣️ OSRM Project** for open-source routing engine
- **🌤️ Open-Meteo** for free, high-quality weather data
- **📱 Flutter Team** for the amazing cross-platform framework
- **� Flutter Community** for excellent plugins and packages

## 📞 Support

Need help or found a bug?

1. **📖 Check the [Troubleshooting](#-troubleshooting) section**
2. **🔍 Search existing [Issues](https://github.com/NaurasShaji/TrafficAlarm/issues)**
3. **🆕 Create a [new issue](https://github.com/NaurasShaji/TrafficAlarm/issues/new)** with:
   - Device model and OS version
   - App version and configuration
   - Steps to reproduce the problem
   - Screenshots if applicable

## 🔮 Roadmap & Future Features

### 🚀 **Planned Features**
- [ ] **📅 Calendar Integration**: Automatic alarms for calendar events
- [ ] **⏰ Multiple Alarms**: Support for recurring and multiple destinations
- [ ] **🎵 Custom Sounds**: Upload personal alarm tones
- [ ] **📱 Widget Support**: Home screen alarm status widget
- [ ] **🌙 Sleep Tracking**: Optimal wake-up time based on sleep cycles

### 🌟 **Advanced Features**
- [ ] **🗣️ Voice Commands**: "Set alarm for work tomorrow at 9 AM"
- [ ] **⌚ Smartwatch Support**: Apple Watch and Wear OS integration
- [ ] **🏠 Smart Home**: Integration with Alexa, Google Home
- [ ] **🚌 Public Transit**: Bus and train schedule integration
- [ ] **👥 Carpool Coordination**: Shared ride timing for teams

### 🛠️ **Technical Improvements**
- [ ] **📱 Offline Mode**: Cached routes for emergency use
- [ ] **🔋 Battery Optimization**: Enhanced background processing
- [ ] **🌐 Web App**: Progressive Web App version
- [ ] **🎨 Themes**: Dark mode and custom color schemes
- [ ] **🌍 Localization**: Multi-language support

---

## ⭐ **Star This Project!**

If this app makes your mornings better, please give it a star ⭐ on GitHub!

**Made with ❤️ for stress-free mornings and perfect timing!**

---

### 📊 **Project Stats**
- **🆓 100% Free Core Features** - No API costs required
- **🌍 Global Coverage** - Works anywhere with OpenStreetMap data  
- **📱 Cross-Platform** - iOS and Android support
- **🔓 Open Source** - MIT License, contribute freely
- **🚀 Active Development** - Regular updates and improvements