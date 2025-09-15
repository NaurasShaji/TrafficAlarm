import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SpotifyTrack {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String? imageUrl;
  final int durationMs;
  final String previewUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    this.imageUrl,
    required this.durationMs,
    required this.previewUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'album': album,
      'imageUrl': imageUrl,
      'durationMs': durationMs,
      'previewUrl': previewUrl,
    };
  }

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'],
      name: json['name'],
      artist: json['artists'][0]['name'],
      album: json['album']['name'],
      imageUrl: json['album']['images'].isNotEmpty 
          ? json['album']['images'][0]['url'] 
          : null,
      durationMs: json['duration_ms'],
      previewUrl: json['preview_url'] ?? '',
    );
  }

  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int trackCount;
  final List<SpotifyTrack> tracks;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.trackCount,
    required this.tracks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'trackCount': trackCount,
      'tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: json['images'].isNotEmpty 
          ? json['images'][0]['url'] 
          : null,
      trackCount: json['tracks']['total'],
      tracks: (json['tracks']['items'] as List)
          .map((item) => SpotifyTrack.fromJson(item['track']))
          .toList(),
    );
  }
}

class SpotifyService {
  static String get _clientId => ApiConfig.spotifyClientId;
  static String get _clientSecret => ApiConfig.spotifyClientSecret;
  static const String _baseUrl = 'https://api.spotify.com/v1';
  
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Get access token for Spotify API
  Future<String> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
        return _accessToken!;
      }
      throw Exception('Failed to get access token: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to authenticate with Spotify: $e');
    }
  }

  /// Search for morning playlists
  Future<List<SpotifyPlaylist>> searchMorningPlaylists() async {
    try {
      final token = await _getAccessToken();
      
      final url = Uri.parse(
        '$_baseUrl/search?q=morning%20wake%20up%20playlist&type=playlist&limit=10',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final playlists = data['playlists']['items'] as List;
        
        return playlists.map((playlist) => SpotifyPlaylist.fromJson(playlist)).toList();
      }
      throw Exception('Failed to search playlists: ${response.statusCode}');
    } catch (e) {
      // Return mock playlists if API fails
      return _getMockPlaylists();
    }
  }

  /// Get featured playlists
  Future<List<SpotifyPlaylist>> getFeaturedPlaylists() async {
    try {
      final token = await _getAccessToken();
      
      final url = Uri.parse('$_baseUrl/browse/featured-playlists?limit=10');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final playlists = data['playlists']['items'] as List;
        
        return playlists.map((playlist) => SpotifyPlaylist.fromJson(playlist)).toList();
      }
      throw Exception('Failed to get featured playlists: ${response.statusCode}');
    } catch (e) {
      return _getMockPlaylists();
    }
  }

  /// Search for specific music
  Future<List<SpotifyTrack>> searchTracks(String query) async {
    try {
      final token = await _getAccessToken();
      
      final url = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&type=track&limit=20',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = data['tracks']['items'] as List;
        
        return tracks.map((track) => SpotifyTrack.fromJson(track)).toList();
      }
      throw Exception('Failed to search tracks: ${response.statusCode}');
    } catch (e) {
      return _getMockTracks();
    }
  }

  /// Get morning motivation tracks
  Future<List<SpotifyTrack>> getMorningMotivationTracks() async {
    return await searchTracks('morning motivation upbeat');
  }

  /// Mock playlists for testing when API is not available
  List<SpotifyPlaylist> _getMockPlaylists() {
    return [
      SpotifyPlaylist(
        id: 'mock1',
        name: 'Morning Energy',
        description: 'Start your day with high-energy tracks',
        imageUrl: 'https://via.placeholder.com/300x300',
        trackCount: 25,
        tracks: _getMockTracks(),
      ),
      SpotifyPlaylist(
        id: 'mock2',
        name: 'Wake Up & Go',
        description: 'Perfect playlist to get you moving in the morning',
        imageUrl: 'https://via.placeholder.com/300x300',
        trackCount: 30,
        tracks: _getMockTracks(),
      ),
      SpotifyPlaylist(
        id: 'mock3',
        name: 'Morning Motivation',
        description: 'Inspirational songs to kickstart your day',
        imageUrl: 'https://via.placeholder.com/300x300',
        trackCount: 20,
        tracks: _getMockTracks(),
      ),
    ];
  }

  /// Mock tracks for testing
  List<SpotifyTrack> _getMockTracks() {
    return [
      SpotifyTrack(
        id: 'track1',
        name: 'Good Morning',
        artist: 'Kanye West',
        album: 'Graduation',
        imageUrl: 'https://via.placeholder.com/300x300',
        durationMs: 180000,
        previewUrl: '',
      ),
      SpotifyTrack(
        id: 'track2',
        name: 'Wake Me Up',
        artist: 'Avicii',
        album: 'True',
        imageUrl: 'https://via.placeholder.com/300x300',
        durationMs: 247000,
        previewUrl: '',
      ),
      SpotifyTrack(
        id: 'track3',
        name: 'Here Comes the Sun',
        artist: 'The Beatles',
        album: 'Abbey Road',
        imageUrl: 'https://via.placeholder.com/300x300',
        durationMs: 185000,
        previewUrl: '',
      ),
    ];
  }

  /// Get Spotify app URL for opening in the app
  String getSpotifyAppUrl(String trackId) {
    return 'spotify:track:$trackId';
  }

  /// Get web URL for opening in browser
  String getSpotifyWebUrl(String trackId) {
    return 'https://open.spotify.com/track/$trackId';
  }
}
