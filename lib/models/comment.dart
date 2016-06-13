import 'package:app_news_portal/models/user.dart';

class Comment {
  final int id;
  final String content;
  final int userId;
  final int newsId;
  final User? user;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.newsId,
    this.user,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userId: int.parse(json['user_id'].toString()),
      newsId: int.parse(json['news_id'].toString()),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
