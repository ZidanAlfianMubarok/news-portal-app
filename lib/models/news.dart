import 'package:app_news_portal/models/user.dart';
import 'package:app_news_portal/models/comment.dart';

import 'package:flutter/foundation.dart';
import '../config.dart';

class News {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final int userId;
  final User? author;
  final List<Comment>? comments;
  final DateTime? createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.userId,
    this.author,
    this.comments,
    this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    String? imgUrl = json['image_url'];

    // Fix for Web: Replace host with Config.baseUrl host if different
    // This handles cases where DB has IP address but we are on localhost
    if (kIsWeb && imgUrl != null) {
      try {
        final uri = Uri.parse(imgUrl);
        final baseUri = Uri.parse(Config.baseUrl);
        if (uri.host != baseUri.host) {
          imgUrl = uri.replace(host: baseUri.host).toString();
        }
      } catch (e) {
        debugPrint('Error parsing image URL: $e');
      }
    }

    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: imgUrl,
      userId: int.parse(json['author_id'].toString()),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((i) => Comment.fromJson(i)).toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
