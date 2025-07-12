import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';
import '../config/app_config.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static String get _apiKey => AppConfig.newsApiKey;

  /// Fetch environmental news articles
  Future<NewsResponse> getEnvironmentalNews({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!AppConfig.hasNewsApiKey) {
      throw Exception('NEWS_API_KEY not found in environment variables');
    }
    
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/everything?'
          'q=(environment OR climate OR "global warming" OR "renewable energy" OR '
          '"climate change" OR "environmental protection" OR "green energy" OR '
          '"carbon footprint" OR sustainability OR "eco friendly" OR "clean energy")&'
          'language=en&'
          'sortBy=publishedAt&'
          'page=$page&'
          'pageSize=$pageSize&'
          'apiKey=$_apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  /// Fetch top environmental headlines
  Future<NewsResponse> getTopEnvironmentalHeadlines({
    String country = 'us',
    int pageSize = 20,
  }) async {
    if (!AppConfig.hasNewsApiKey) {
      throw Exception('NEWS_API_KEY not found in environment variables');
    }
    
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/top-headlines?'
          'q=environment OR climate&'
          'country=$country&'
          'pageSize=$pageSize&'
          'apiKey=$_apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load headlines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching headlines: $e');
    }
  }

  /// Search for specific environmental topics
  Future<NewsResponse> searchEnvironmentalNews({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!AppConfig.hasNewsApiKey) {
      throw Exception('NEWS_API_KEY not found in environment variables');
    }
    
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/everything?'
          'q=($query) AND (environment OR climate OR green OR eco)&'
          'language=en&'
          'sortBy=publishedAt&'
          'page=$page&'
          'pageSize=$pageSize&'
          'apiKey=$_apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }
}

class AIService {
  // For AI summarization, I recommend using Google's Gemini API
  // It's more cost-effective and performs better for summarization tasks
  // You can get a free API key from: https://makersuite.google.com/app/apikey
  
  static String get _geminiApiKey => AppConfig.geminiApiKey;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Summarize article using Gemini AI
  Future<String> summarizeArticle(NewsArticle article) async {
    if (!AppConfig.hasGeminiApiKey) {
      // Return a placeholder summary if API key is not set
      return 'AI Summary: This article discusses ${article.title.toLowerCase()}. '
             'The content covers environmental topics and sustainability initiatives. '
             'Published by ${article.source} on ${_formatDate(article.publishedAt)}. '
             'Key points include environmental protection, climate action, and green technology developments.';
    }

    try {
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': 'Please provide a concise summary (2-3 sentences) of this environmental news article. '
                       'Focus on the key environmental impact, actions being taken, and significance:\n\n'
                       'Title: ${article.title}\n'
                       'Content: ${article.description}\n'
                       '${article.content.isNotEmpty ? article.content : ""}'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 150,
        }
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final summary = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return summary.isNotEmpty ? summary : _generateFallbackSummary(article);
      } else {
        return _generateFallbackSummary(article);
      }
    } catch (e) {
      return _generateFallbackSummary(article);
    }
  }

  String _generateFallbackSummary(NewsArticle article) {
    final date = _formatDate(article.publishedAt);
    return 'Summary: ${article.title} - This environmental news article from ${article.source} '
           'published on $date discusses important sustainability and climate-related topics. '
           '${article.description.isNotEmpty ? article.description.substring(0, article.description.length > 100 ? 100 : article.description.length) + "..." : ""}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/* 
AI Recommendation: Google Gemini vs OpenAI

I recommend using Google Gemini for your news summarization because:

1. **Cost-Effective**: Gemini offers generous free tier (15 requests per minute)
2. **Better for Summarization**: Optimized for text understanding and summarization
3. **Faster Response**: Generally lower latency than OpenAI
4. **Free API Key**: Easy to get started with no payment required
5. **Good Performance**: Excellent quality for news summarization tasks

OpenAI GPT would be better for:
- Complex reasoning tasks
- Creative writing
- More complex conversations

For news summarization specifically, Gemini is the better choice.

To set up Gemini:
1. Go to https://makersuite.google.com/app/apikey
2. Create a new API key
3. Replace 'YOUR_GEMINI_API_KEY_HERE' with your actual key
*/
