import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.isAllDay = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'isAllDay': isAllDay,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['summary'] ?? json['title'],
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start']['dateTime'] ?? json['start']['date']),
      endTime: DateTime.parse(json['end']['dateTime'] ?? json['end']['date']),
      location: json['location'] ?? '',
      isAllDay: json['start']['date'] != null,
    );
  }

  /// Check if this event is happening today
  bool get isToday {
    final now = DateTime.now();
    final eventDate = startTime;
    return now.year == eventDate.year &&
           now.month == eventDate.month &&
           now.day == eventDate.day;
  }

  /// Check if this event is happening tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final eventDate = startTime;
    return tomorrow.year == eventDate.year &&
           tomorrow.month == eventDate.month &&
           tomorrow.day == eventDate.day;
  }

  /// Get time until event starts
  Duration get timeUntilStart => startTime.difference(DateTime.now());

  /// Check if event is starting soon (within next 2 hours)
  bool get isStartingSoon => timeUntilStart.inHours <= 2 && timeUntilStart.inMinutes > 0;
}

class CalendarService {
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Get access token for Google Calendar API
  Future<String> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    // In a real implementation, you would use OAuth2 flow
    // For now, return a placeholder
    throw Exception('Calendar integration requires OAuth2 setup');
  }

  /// Get today's events
  Future<List<CalendarEvent>> getTodaysEvents() async {
    try {
      if (!ApiConfig.isCalendarConfigured) {
        return _getMockTodaysEvents();
      }

      final token = await _getAccessToken();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final url = Uri.parse(
        '$_baseUrl/calendars/primary/events?'
        'timeMin=${startOfDay.toIso8601String()}Z&'
        'timeMax=${endOfDay.toIso8601String()}Z&'
        'singleEvents=true&'
        'orderBy=startTime',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['items'] as List;
        
        return events
            .map((event) => CalendarEvent.fromJson(event))
            .toList();
      }
      throw Exception('Failed to load calendar events: ${response.statusCode}');
    } catch (e) {
      // Return mock events if API fails
      return _getMockTodaysEvents();
    }
  }

  /// Get tomorrow's events
  Future<List<CalendarEvent>> getTomorrowsEvents() async {
    try {
      if (!ApiConfig.isCalendarConfigured) {
        return _getMockTomorrowsEvents();
      }

      final token = await _getAccessToken();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final url = Uri.parse(
        '$_baseUrl/calendars/primary/events?'
        'timeMin=${startOfDay.toIso8601String()}Z&'
        'timeMax=${endOfDay.toIso8601String()}Z&'
        'singleEvents=true&'
        'orderBy=startTime',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['items'] as List;
        
        return events
            .map((event) => CalendarEvent.fromJson(event))
            .toList();
      }
      throw Exception('Failed to load calendar events: ${response.statusCode}');
    } catch (e) {
      return _getMockTomorrowsEvents();
    }
  }

  /// Get events starting soon (within next 2 hours)
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    final todaysEvents = await getTodaysEvents();
    return todaysEvents.where((event) => event.isStartingSoon).toList();
  }

  /// Check if there are any important meetings today
  bool hasImportantMeetings(List<CalendarEvent> events) {
    return events.any((event) => 
      event.title.toLowerCase().contains('meeting') ||
      event.title.toLowerCase().contains('interview') ||
      event.title.toLowerCase().contains('presentation') ||
      event.title.toLowerCase().contains('conference')
    );
  }

  /// Get next important meeting
  CalendarEvent? getNextImportantMeeting(List<CalendarEvent> events) {
    final importantEvents = events.where((event) => 
      event.title.toLowerCase().contains('meeting') ||
      event.title.toLowerCase().contains('interview') ||
      event.title.toLowerCase().contains('presentation') ||
      event.title.toLowerCase().contains('conference')
    ).toList();

    if (importantEvents.isEmpty) return null;

    importantEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    return importantEvents.first;
  }

  /// Mock today's events for testing
  List<CalendarEvent> _getMockTodaysEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: 'mock1',
        title: 'Team Standup',
        description: 'Daily team standup meeting',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 1, minutes: 30)),
        location: 'Conference Room A',
      ),
      CalendarEvent(
        id: 'mock2',
        title: 'Client Presentation',
        description: 'Present quarterly results to client',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 4)),
        location: 'Main Conference Room',
      ),
      CalendarEvent(
        id: 'mock3',
        title: 'Lunch with Sarah',
        description: 'Catch up over lunch',
        startTime: now.add(const Duration(hours: 5)),
        endTime: now.add(const Duration(hours: 6)),
        location: 'Downtown Restaurant',
      ),
    ];
  }

  /// Mock tomorrow's events for testing
  List<CalendarEvent> _getMockTomorrowsEvents() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return [
      CalendarEvent(
        id: 'mock4',
        title: 'Project Review',
        description: 'Review project progress and next steps',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        location: 'Office',
      ),
      CalendarEvent(
        id: 'mock5',
        title: 'Doctor Appointment',
        description: 'Annual checkup',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 0),
        location: 'Medical Center',
      ),
    ];
  }

  /// Get calendar summary for morning briefing
  String getCalendarSummary(List<CalendarEvent> events) {
    if (events.isEmpty) {
      return '📅 No meetings scheduled today. Enjoy your free time!';
    }

    final importantMeetings = events.where((event) => 
      event.title.toLowerCase().contains('meeting') ||
      event.title.toLowerCase().contains('interview') ||
      event.title.toLowerCase().contains('presentation')
    ).length;

    final nextEvent = events.isNotEmpty ? events.first : null;
    
    String summary = '📅 Today\'s Schedule:\n';
    summary += '• $importantMeetings important meetings\n';
    
    if (nextEvent != null) {
      final timeUntil = nextEvent.timeUntilStart;
      if (timeUntil.inHours > 0) {
        summary += '• Next: ${nextEvent.title} in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
      } else {
        summary += '• Next: ${nextEvent.title} in ${timeUntil.inMinutes}m';
      }
    }

    return summary;
  }
}
