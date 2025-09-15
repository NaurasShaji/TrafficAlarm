import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

enum AlarmSoundType {
  gentle,
  urgent,
  notification,
}

class AlarmSoundService {
  static final AlarmSoundService _instance = AlarmSoundService._internal();
  factory AlarmSoundService() => _instance;
  AlarmSoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Timer? _alarmTimer;

  // Sound file paths
  static const Map<AlarmSoundType, String> _soundPaths = {
    AlarmSoundType.gentle: 'audio/alarm_gentle.mp3',
    AlarmSoundType.urgent: 'audio/alarm_urgent.mp3',
    AlarmSoundType.notification: 'audio/notification_chime.mp3',
  };

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      debugPrint('AlarmSoundService: Initialized successfully');
    } catch (e) {
      debugPrint('AlarmSoundService: Failed to initialize: $e');
    }
  }

  /// Play an alarm sound
  Future<void> playAlarm({
    AlarmSoundType type = AlarmSoundType.gentle,
    bool loop = false,
    double volume = 0.8,
    Duration? duration,
  }) async {
    try {
      if (_isPlaying) {
        await stopAlarm();
      }

      // Try to play from assets first, fallback to system sound
      bool soundPlayed = false;
      
      try {
        final soundPath = _soundPaths[type]!;
        await _audioPlayer.setSource(AssetSource(soundPath));
        await _audioPlayer.setVolume(volume);
        
        if (loop) {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        } else {
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        }
        
        await _audioPlayer.resume();
        soundPlayed = true;
        debugPrint('AlarmSoundService: Playing ${type.name} alarm from asset');
      } catch (e) {
        debugPrint('AlarmSoundService: Asset sound failed, using system sound: $e');
        // Fallback to system sound
        await _playSystemSound(type);
        soundPlayed = true;
      }

      if (soundPlayed) {
        _isPlaying = true;
        
        // If duration is specified and not looping, stop after duration
        if (duration != null && !loop) {
          _alarmTimer = Timer(duration, () {
            stopAlarm();
          });
        }
        
        // If looping and duration specified, stop after duration
        if (duration != null && loop) {
          _alarmTimer = Timer(duration, () {
            stopAlarm();
          });
        }
      }
    } catch (e) {
      debugPrint('AlarmSoundService: Failed to play alarm: $e');
      // Last resort: system beep
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Play system sound as fallback
  Future<void> _playSystemSound(AlarmSoundType type) async {
    switch (type) {
      case AlarmSoundType.gentle:
      case AlarmSoundType.notification:
        SystemSound.play(SystemSoundType.alert);
        break;
      case AlarmSoundType.urgent:
        // Play multiple system sounds for urgency
        for (int i = 0; i < 3; i++) {
          SystemSound.play(SystemSoundType.alert);
          await Future.delayed(const Duration(milliseconds: 500));
        }
        break;
    }
  }

  /// Stop the current alarm
  Future<void> stopAlarm() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        _isPlaying = false;
        _alarmTimer?.cancel();
        _alarmTimer = null;
        debugPrint('AlarmSoundService: Alarm stopped');
      }
    } catch (e) {
      debugPrint('AlarmSoundService: Failed to stop alarm: $e');
    }
  }

  /// Check if alarm is currently playing
  bool get isPlaying => _isPlaying;

  /// Play a gentle wake-up alarm (for estimated time)
  Future<void> playGentleAlarm({Duration? duration}) async {
    await playAlarm(
      type: AlarmSoundType.gentle,
      loop: true,
      volume: 0.6,
      duration: duration ?? const Duration(seconds: 30),
    );
  }

  /// Play an urgent alarm (for set time)
  Future<void> playUrgentAlarm({Duration? duration}) async {
    await playAlarm(
      type: AlarmSoundType.urgent,
      loop: true,
      volume: 0.9,
      duration: duration ?? const Duration(minutes: 2),
    );
  }

  /// Play a notification sound
  Future<void> playNotification() async {
    await playAlarm(
      type: AlarmSoundType.notification,
      loop: false,
      volume: 0.7,
    );
  }

  /// Set volume for alarm sounds
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('AlarmSoundService: Failed to set volume: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
  }
}