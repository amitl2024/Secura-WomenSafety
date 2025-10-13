class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? 'Unknown Source',
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }
}

class NewsNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime createdAt;
  final bool isRead;

  NewsNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    required this.createdAt,
    this.isRead = false,
  });

  factory NewsNotification.fromJson(Map<String, dynamic> json) {
    return NewsNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}


