import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  static final String? _newsApiKey = dotenv.env['NEWS_API_KEY'];
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Safety-related keywords for news filtering
  static const List<String> _safetyKeywords = [
    'women safety',
    'women security',
    'domestic violence',
    'sexual harassment',
    'women empowerment',
    'gender equality',
    'women rights',
    'safety tips',
    'emergency services',
    'women protection',
    'crime against women',
    'women safety app',
    'self defense',
    'women helpline',
    'safety awareness',
  ];

  static Future<List<NewsArticle>> getSafetyNews({
    int pageSize = 10,
    String country = 'in', // India by default
  }) async {
    try {
      print('📰 Fetching safety news...');

      final query = _safetyKeywords.join(' OR ');
      final url =
          '$_baseUrl/everything?'
          'q=$query&'
          'language=en&'
          'sortBy=publishedAt&'
          'pageSize=$pageSize&'
          'apiKey=$_newsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<NewsArticle> articles = [];

        for (var article in data['articles']) {
          if (article['title'] != null && article['description'] != null) {
            articles.add(NewsArticle.fromJson(article));
          }
        }

        return articles;
      } else {
        print('❌ News API error: ${response.statusCode}');
        return _getMockSafetyNews();
      }
    } catch (e) {
      print('❌ Error fetching news: $e');
      return _getMockSafetyNews();
    }
  }

  static Future<List<NewsArticle>> getTopHeadlines({
    String category = 'general',
    String country = 'in',
    int pageSize = 5,
  }) async {
    try {
      print('📰 Fetching top headlines...');

      // return _getMockTopHeadlines();

      final url =
          '$_baseUrl/top-headlines?'
          'country=$country&'
          'category=$category&'
          'pageSize=$pageSize&'
          'apiKey=$_newsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<NewsArticle> articles = [];

        for (var article in data['articles']) {
          if (article['title'] != null && article['description'] != null) {
            articles.add(NewsArticle.fromJson(article));
          }
        }

        return articles;
      } else {
        print('❌ News API error: ${response.statusCode}');
        return _getMockTopHeadlines();
      }
    } catch (e) {
      print('❌ Error fetching headlines: $e');
      return _getMockTopHeadlines();
    }
  }

  // Mock data for development
  static List<NewsArticle> _getMockSafetyNews() {
    return [
      NewsArticle(
        title: 'New Women Safety Initiative Launched in Major Cities',
        description:
            'A comprehensive women safety program has been introduced across major metropolitan areas, focusing on improved street lighting and emergency response systems.',
        url: 'https://example.com/news1',
        urlToImage:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Safety News',
      ),
      NewsArticle(
        title: 'Self-Defense Training Programs See 300% Increase in Enrollment',
        description:
            'More women are taking up self-defense classes as awareness about personal safety grows in urban areas.',
        url: 'https://example.com/news2',
        urlToImage:
            'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        source: 'Women\'s Safety Today',
      ),
      NewsArticle(
        title: 'Emergency Helpline Numbers Now Available in 15 Languages',
        description:
            'The national women helpline has expanded its language support to better serve diverse communities across the country.',
        url: 'https://example.com/news3',
        urlToImage:
            'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: 'Safety First',
      ),
      NewsArticle(
        title: 'Technology Apps Helping Women Stay Safe During Commute',
        description:
            'Mobile applications with real-time location sharing and emergency features are becoming increasingly popular among working women.',
        url: 'https://example.com/news4',
        urlToImage:
            'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        source: 'Tech Safety',
      ),
      NewsArticle(
        title:
            'Community Watch Programs Show 40% Reduction in Street Harassment',
        description:
            'Neighborhood safety initiatives are proving effective in creating safer environments for women and children.',
        url: 'https://example.com/news5',
        urlToImage:
            'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        source: 'Community Safety',
      ),
    ];
  }

  static List<NewsArticle> _getMockTopHeadlines() {
    return [
      NewsArticle(
        title: 'Breaking: New Women Safety Bill Passed in Parliament',
        description:
            'The landmark legislation introduces stricter penalties and better protection measures for women across the country.',
        url: 'https://example.com/headline1',
        urlToImage:
            'https://images.unsplash.com/photo-1556075798-4825dfaaf498?w=400',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        source: 'National News',
      ),
      NewsArticle(
        title: 'Emergency Response Time Improved by 50% in Major Cities',
        description:
            'New technology and better coordination have significantly reduced response times for women safety emergencies.',
        url: 'https://example.com/headline2',
        urlToImage:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
        source: 'Emergency Services',
      ),
    ];
  }
}
