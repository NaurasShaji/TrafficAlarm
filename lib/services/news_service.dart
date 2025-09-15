import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      description: json['description'] ?? '',
      url: json['url'],
      source: json['source']['name'] ?? 'Unknown',
      publishedAt: DateTime.parse(json['publishedAt']),
      imageUrl: json['urlToImage'],
    );
  }
}

class NewsService {
  static String get _apiKey => ApiConfig.newsApiKey;
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';

  /// Get top headlines for morning briefing
  Future<List<NewsArticle>> getTopHeadlines({
    String country = 'us',
    String category = 'general',
    int pageSize = 5,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?country=$country&category=$category&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          final articles = data['articles'] as List;
          return articles
              .map((article) => NewsArticle.fromJson(article))
              .toList();
        }
      }
      throw Exception('Failed to load news: ${response.statusCode}');
    } catch (e) {
      // Return mock news if API fails
      return _getMockNews();
    }
  }

  /// Get news by search query
  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=${Uri.encodeComponent(query)}&sortBy=publishedAt&pageSize=5&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          final articles = data['articles'] as List;
          return articles
              .map((article) => NewsArticle.fromJson(article))
              .toList();
        }
      }
      throw Exception('Failed to search news: ${response.statusCode}');
    } catch (e) {
      return _getMockNews();
    }
  }

  /// Mock news data for testing when API is not available
  List<NewsArticle> _getMockNews() {
    return [
      NewsArticle(
        title: 'Traffic Alert: Major Highway Closure Expected',
        description: 'Local authorities announce planned maintenance on Highway 101 that may affect morning commute.',
        url: 'https://example.com/news1',
        source: 'Local News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: 'https://via.placeholder.com/300x200',
      ),
      NewsArticle(
        title: 'Weather Update: Clear Skies Expected Today',
        description: 'Meteorologists predict sunny conditions with temperatures reaching 75°F.',
        url: 'https://example.com/news2',
        source: 'Weather Channel',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
        imageUrl: 'https://via.placeholder.com/300x200',
      ),
      NewsArticle(
        title: 'Tech Stocks Rise as Market Opens',
        description: 'Major technology companies see gains in early morning trading.',
        url: 'https://example.com/news3',
        source: 'Financial Times',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        imageUrl: 'https://via.placeholder.com/300x200',
      ),
      NewsArticle(
        title: 'New Public Transportation Initiative Launched',
        description: 'City officials announce expanded bus routes to improve connectivity.',
        url: 'https://example.com/news4',
        source: 'City News',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        imageUrl: 'https://via.placeholder.com/300x200',
      ),
      NewsArticle(
        title: 'Local Sports Team Wins Championship',
        description: 'Hometown team secures victory in regional tournament finals.',
        url: 'https://example.com/news5',
        source: 'Sports Daily',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        imageUrl: 'https://via.placeholder.com/300x200',
      ),
    ];
  }

  /// Get a brief morning news summary
  String getMorningBriefing(List<NewsArticle> articles) {
    if (articles.isEmpty) return 'No news available this morning.';

    final headlines = articles.take(3).map((article) => '• ${article.title}').join('\n');
    return '📰 Morning Briefing:\n\n$headlines';
  }
}
