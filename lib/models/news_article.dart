class NewsArticle {
  final String title;
  final String description;
  final String content;
  final String url;
  final String? urlToImage;
  final String author;
  final DateTime publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    this.urlToImage,
    required this.author,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      author: json['author'] ?? 'Unknown Author',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']['name'] ?? 'Unknown Source',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': urlToImage,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'source': source,
    };
  }
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((article) => NewsArticle.fromJson(article))
              .toList() ??
          [],
    );
  }
}
