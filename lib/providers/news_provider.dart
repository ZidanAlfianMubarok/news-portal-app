import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/news.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<News> _newsList = [];
  bool _isLoading = false;

  List<News> get newsList => _newsList;
  bool get isLoading => _isLoading;

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();
    try {
      _newsList = await _apiService.getNews();
    } catch (e) {
      debugPrint('Fetch News Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<News?> fetchNewsById(int id) async {
    try {
      return await _apiService.getNewsById(id);
    } catch (e) {
      debugPrint('Fetch News Detail Error: $e');
      return null;
    }
  }

  Future<String?> createNews(String title, String content, XFile? image) async {
    final error = await _apiService.createNews(title, content, image);
    if (error == null) {
      await fetchNews();
    }
    return error;
  }

  Future<String?> updateNews(
      int id, String title, String content, XFile? image) async {
    final error = await _apiService.updateNews(id, title, content, image);
    if (error == null) {
      await fetchNews();
    }
    return error;
  }

  Future<bool> deleteNews(int id) async {
    final success = await _apiService.deleteNews(id);
    if (success) {
      _newsList.removeWhere((element) => element.id == id);
      notifyListeners();
    }
    return success;
  }

  // Comments logic can be here or in a separate provider, putting here for simplicity
  Future<List<Comment>> fetchComments(int newsId) async {
    return await _apiService.getComments(newsId);
  }

  Future<bool> addComment(int newsId, String content) async {
    return await _apiService.createComment(newsId, content);
  }

  Future<bool> deleteComment(int commentId) async {
    return await _apiService.deleteComment(commentId);
  }
}
