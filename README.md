# Traffic Alarm - Smart Traffic-Aware Alarm Clock

A sophisticated Flutter application that serves as an intelligent alarm clock, automatically adjusting wake-up times based on real-time traffic conditions to ensure you always arrive at your destination on time.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

## 🚀 Features

### Core Functionality
- **Smart Alarm System**: Set alarms based on arrival time rather than wake-up time
- **Real-time Traffic Monitoring**: Continuously monitors traffic conditions to your destination
- **Dynamic Alarm Adjustment**: Automatically adjusts wake-up time if traffic conditions worsen
- **Multi-Platform Support**: Runs on Android, iOS, Web, Windows, macOS, and Linux
- **Background Processing**: Monitors traffic even when the app is closed (mobile platforms)
- **Local Notifications**: Rich notifications with sound and vibration support

### User Interface
- **Material Design 3**: Modern, clean interface following Google's latest design guidelines
- **Responsive Layout**: Adapts to different screen sizes and orientations
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Intuitive Setup**: Easy-to-use alarm configuration with visual feedback

### Advanced Features
- **Traffic Buffer Time**: Configurable buffer time for unexpected delays
- **Multiple Alarm Support**: Set multiple traffic-aware alarms
- **Notification Channels**: Organized notification categories for better control
- **Cross-Platform Compatibility**: Graceful degradation on platforms with limited features

## 📱 Screenshots

| Home Screen | Alarm Setup | Alarm Active |
|-------------|-------------|--------------|
| ![Home](screenshots/home.png) | ![Setup](screenshots/setup.png) | ![Active](screenshots/active.png) |

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # Application entry point
├── models/
│   ├── alarm_settings.dart      # Alarm configuration data model
│   └── traffic_data.dart        # Traffic information data model
├── screens/
│   ├── home_screen.dart         # Main application screen
│   ├── alarm_setup_screen.dart  # Alarm configuration interface
│   └── alarm_display_screen.dart # Active alarm display
└── services/
    ├── alarm_manager.dart       # Core alarm management logic
    ├── background_service.dart  # Background task coordination
    ├── notification_service.dart # Local notification handling
    └── traffic_service.dart     # Traffic data API integration
```

### Service Architecture
- **AlarmManager**: Central service managing alarm state and persistence
- **TrafficService**: Handles API calls to traffic information providers
- **NotificationService**: Cross-platform notification management
- **BackgroundService**: Coordinates background tasks (mobile only)

## 🛠️ Installation & Setup

### Prerequisites
- **Flutter SDK**: Version 3.10.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Development Environment**: 
  - Android Studio / VS Code for development
  - Xcode (for iOS development on macOS)
  - Visual Studio (for Windows development)

### Quick Start
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/traffic-alarm.git
   cd traffic-alarm
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # For mobile/desktop
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For specific platform
   flutter run -d windows
   flutter run -d android
   flutter run -d ios
   ```

### Platform-Specific Setup

#### Android
- **Minimum SDK**: API level 21 (Android 5.0)
- **Target SDK**: API level 34 (Android 14)
- **Permissions**: Automatically configured in `android/app/src/main/AndroidManifest.xml`

#### iOS
- **Minimum Version**: iOS 12.0
- **Permissions**: Configure in `ios/Runner/Info.plist`

#### Windows
- **Requirements**: Windows 10 version 1903 or higher
- **Build Tools**: Visual Studio 2019 or higher with C++ tools

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6           # iOS-style icons
  flutter_local_notifications: ^17.2.2  # Local notification support
  provider: ^6.1.1                  # State management
  shared_preferences: ^2.2.2        # Local data persistence
  http: ^1.1.0                      # HTTP client for API calls
  workmanager: ^0.5.2              # Background task management (mobile)
  permission_handler: ^11.3.1       # Runtime permission handling
  timezone: ^0.9.2                  # Timezone-aware date/time
  intl: ^0.18.1                     # Internationalization support
  uuid: ^4.2.2                      # Unique identifier generation
  logger: ^2.0.2                    # Logging utilities

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1            # Dart/Flutter linting rules
  build_runner: ^2.4.7             # Code generation tool
```

### Platform Support Matrix
| Feature | Android | iOS | Web | Windows | macOS | Linux |
|---------|---------|-----|-----|---------|-------|-------|
| Core Alarm | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Background Tasks | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Scheduled Notifications | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Immediate Notifications | ✅ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ |
| Traffic API | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

*⚠️ = Limited support, ❌ = Not supported*

## 🔧 Configuration

### Environment Setup
1. **Traffic API Configuration**:
   ```dart
   // lib/services/traffic_service.dart
   class TrafficService {
     static const String _apiKey = 'YOUR_API_KEY_HERE';
     static const String _baseUrl = 'https://api.traffic-provider.com';
   }
   ```

2. **Notification Channels** (Android):
   ```dart
   // Automatically configured in NotificationService
   static const String _channelId = 'traffic_alarm_channel';
   static const String _channelName = 'Traffic Alarm';
   ```

### Build Configuration

#### Development Build
```bash
flutter run --debug
```

#### Production Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --web-renderer html

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🎯 Usage Guide

### Setting Up Your First Alarm

1. **Launch the Application**: Open Traffic Alarm on your device
2. **Access Alarm Setup**: Tap "Set Smart Alarm" on the home screen
3. **Configure Destination**: 
   - Enter your destination address
   - Use the search functionality for accurate location selection
4. **Set Arrival Time**: Choose when you need to arrive at your destination
5. **Adjust Buffer Time**: Add extra time for unexpected delays (recommended: 10-15 minutes)
6. **Confirm Settings**: Review your configuration and tap "Set Smart Alarm"

### Managing Active Alarms

- **View Active Alarm**: The home screen displays your current alarm status
- **Cancel Alarm**: Use the cancel button to deactivate the alarm
- **Modify Alarm**: Tap "Edit" to adjust settings without recreating the alarm
- **Traffic Updates**: Monitor real-time traffic status and estimated travel time

### Understanding Traffic Adjustments

The app automatically:
- Monitors traffic conditions every 15 minutes
- Adjusts wake-up time if delays are detected
- Sends notifications about significant changes
- Maintains your desired arrival time

## 🔔 Notifications

### Notification Types
- **Alarm Notifications**: Wake-up alerts with custom sound
- **Traffic Updates**: Changes in traffic conditions
- **Schedule Adjustments**: Modified wake-up times
- **Arrival Reminders**: Time to leave notifications

### Managing Permissions
The app automatically requests necessary permissions:
- **Notification Permission**: For alarm and update alerts
- **Location Permission**: For accurate traffic monitoring
- **Background App Refresh**: For continuous monitoring

## 🐛 Troubleshooting

### Common Issues

#### App Stuck on Loading Screen
```bash
# Clear app data and restart
flutter clean
flutter pub get
flutter run
```

#### Notifications Not Working
- Check notification permissions in device settings
- Verify Do Not Disturb mode is not blocking alarms
- Ensure the app has background refresh permissions

#### Background Service Issues
- **Android**: Disable battery optimization for the app
- **iOS**: Enable Background App Refresh
- **Desktop**: Background services are not supported

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Platform-Specific Issues

#### Windows
- **Notification Errors**: Scheduled notifications are not supported on Windows
- **Solution**: The app gracefully handles this limitation

#### Web
- **Background Tasks**: Not supported in web browsers
- **Solution**: Use the app actively for traffic monitoring

### Debug Mode
Enable debug logging by setting:
```dart
// In main.dart
debugPrint('Debug mode enabled');
```

## 🚀 Development

### Setting Up Development Environment

1. **Install Flutter**:
   ```bash
   # Follow instructions at https://flutter.dev/docs/get-started/install
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```

3. **IDE Setup**:
   - **VS Code**: Install Flutter and Dart extensions
   - **Android Studio**: Install Flutter plugin

### Code Style
The project follows Flutter's official style guide:
- Use `flutter_lints` for consistent code formatting
- Follow Dart naming conventions
- Implement proper error handling
- Write comprehensive documentation

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

### Contributing

1. **Fork the Repository**
2. **Create Feature Branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit Changes**:
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to Branch**:
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open Pull Request**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Traffic Alarm Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- **Flutter Team**: For the incredible cross-platform framework
- **Google Maps API**: For reliable traffic data (implementation ready)
- **Package Contributors**: All the amazing Flutter package maintainers
- **Open Source Community**: For continuous inspiration and support
- **Beta Testers**: For valuable feedback and bug reports

## 📞 Support

- **Documentation**: [Wiki](https://github.com/yourusername/traffic-alarm/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/traffic-alarm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/traffic-alarm/discussions)
- **Email**: support@trafficalarm.com

## 🗺️ Roadmap

### Version 2.0 (Planned)
- [ ] Multiple destination support
- [ ] Calendar integration
- [ ] Weather-based adjustments
- [ ] Public transit options
- [ ] Smart home integration

### Version 2.1 (Future)
- [ ] Machine learning for personalized predictions
- [ ] Social features and sharing
- [ ] Advanced analytics dashboard
- [ ] Voice assistant integration

---

**Made with ❤️ using Flutter**
