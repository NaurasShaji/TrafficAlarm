import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/alarm_settings.dart';
import '../models/route_data.dart';
import '../models/weather_data.dart';
import '../services/traffic_service.dart';
import '../services/weather_service.dart';
import '../services/news_service.dart';
import '../services/spotify_service.dart';
import '../services/osrm_service.dart';

class AlarmDisplayScreen extends StatefulWidget {
  final AlarmSettings alarm;
  final VoidCallback onCancelAlarm;

  const AlarmDisplayScreen({
    super.key,
    required this.alarm,
    required this.onCancelAlarm,
  });

  @override
  State<AlarmDisplayScreen> createState() => _AlarmDisplayScreenState();
}

class _AlarmDisplayScreenState extends State<AlarmDisplayScreen> {
  final TrafficService _trafficService = TrafficService();
  final WeatherService _weatherService = WeatherService();
  final NewsService _newsService = NewsService();
  final SpotifyService _spotifyService = SpotifyService();
  final OSRMService _osrmService = OSRMService();

  late Timer _timer;
  late Duration _timeRemaining;
  bool _isAlarmTime = false;
  
  RouteData? _routeData;
  WeatherData? _weatherData;
  List<NewsArticle> _newsArticles = [];
  List<SpotifyPlaylist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
    _loadData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final alarmTime = widget.alarm.calculatedAlarmTime!;
    final difference = alarmTime.difference(now);

    setState(() {
      _timeRemaining = difference.isNegative ? Duration.zero : difference;
      _isAlarmTime = _timeRemaining.inSeconds <= 0;
    });
  }

  Future<void> _loadData() async {
    try {
      // Load route data
      final routeData = await _trafficService.getRouteData(widget.alarm.destination);
      
      // Load weather data
      final currentLocation = await _osrmService.getCurrentLocation();
      final weatherData = await _weatherService.getCurrentWeather(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      
      // Load news
      final newsArticles = await _newsService.getTopHeadlines();
      
      // Load morning playlists
      final playlists = await _spotifyService.searchMorningPlaylists();

      if (mounted) {
        setState(() {
          _routeData = routeData;
          _weatherData = weatherData;
          _newsArticles = newsArticles;
          _playlists = playlists;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Countdown Timer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isAlarmTime ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isAlarmTime ? Colors.red[200]! : Colors.blue[200]!,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _isAlarmTime ? '🚨 TIME TO LEAVE!' : '🚦 Smart Alarm Active',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _isAlarmTime ? Colors.red[700] : Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeFormat.format(widget.alarm.calculatedAlarmTime!),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _isAlarmTime ? Colors.red[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(widget.alarm.calculatedAlarmTime!),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _isAlarmTime ? Colors.red[700] : Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Countdown timer
                  Text(
                    _getCountdownText(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: _isAlarmTime ? Colors.red[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Route Information Card
            if (_routeData != null) _buildRouteInfoCard(),
            const SizedBox(height: 16),
            
            // Weather Card
            if (_weatherData != null) _buildWeatherCard(),
            const SizedBox(height: 16),
            
            // News Card
            if (_newsArticles.isNotEmpty) _buildNewsCard(),
            const SizedBox(height: 16),
            
            // Music Card
            if (_playlists.isNotEmpty) _buildMusicCard(),
            const SizedBox(height: 16),
            
            // Destination Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.alarm.destination,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openOpenStreetMap,
                        icon: const Icon(Icons.map),
                        label: const Text('Open in OpenStreetMap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Arrival Time Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ARRIVAL TIME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(
                          '${timeFormat.format(widget.alarm.arrivalTime)} (${widget.alarm.bufferMinutes} min buffer)',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRideOptions,
                    icon: const Icon(Icons.local_taxi),
                    label: const Text('Book Ride'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onCancelAlarm,
                icon: const Icon(Icons.alarm_off),
                label: const Text('Cancel Alarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'ROUTE INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _routeData!.trafficEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_routeData!.formattedDuration} drive',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_routeData!.distanceInKm.toStringAsFixed(1)} km • ${_routeData!.trafficCondition.toUpperCase()} traffic',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_routeData!.hasSignificantTraffic) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Heavy traffic detected! Leave early to arrive on time.',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'WEATHER CONDITIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _weatherData!.weatherEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weatherData!.temperature.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _weatherData!.description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_weatherData!.hasSignificantWeatherImpact) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _weatherService.getWeatherWarning(_weatherData!),
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.newspaper, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'MORNING NEWS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_newsArticles.take(3).map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _launchUrl(article.url),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        article.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'MORNING MUSIC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_playlists.take(2).map((playlist) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _openSpotifyPlaylist(playlist.id),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${playlist.trackCount} tracks',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }

  String _getCountdownText() {
    if (_isAlarmTime) {
      return 'Time to leave now!';
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showRideOptions() async {
    if (_routeData == null) return;

    final urls = await _osrmService.getRideBookingUrls(
      origin: _routeData!.origin,
      destination: _routeData!.destination,
    );

    // Remove OpenStreetMap from ride options since it's now in destination section
    urls.remove('OpenStreetMap');

    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Ride Service',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...urls.entries.map((entry) => ListTile(
                title: Text(entry.key),
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(entry.value);
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              )),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _openOpenStreetMap() async {
    if (_routeData == null) return;

    final urls = await _osrmService.getRideBookingUrls(
      origin: _routeData!.origin,
      destination: _routeData!.destination,
    );

    final openStreetMapUrl = urls['OpenStreetMap'];
    if (openStreetMapUrl != null) {
      await _launchUrl(openStreetMapUrl);
    }
  }

  Future<void> _openSpotifyPlaylist(String playlistId) async {
    final url = _spotifyService.getSpotifyWebUrl(playlistId);
    await _launchUrl(url);
  }
}