import 'package:app_news_portal/models/user.dart';
import 'package:app_news_portal/models/comment.dart';

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
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
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
