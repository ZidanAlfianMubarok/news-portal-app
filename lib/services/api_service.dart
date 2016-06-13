import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http_parser/http_parser.dart';
import '../config.dart';
import '../models/user.dart';
import '../models/news.dart';
import '../models/comment.dart';

class ApiService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    debugPrint('Login Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check for 'access_token' first (standard Laravel Passport), then fallback to 'token'
      final token = data['access_token'] ?? data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String name, String email, String password,
      String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    debugPrint('Register Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] ?? data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('${Config.baseUrl}/logout'),
          headers: await _getHeaders(),
        );
      } catch (e) {
        // Ignore error on logout
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<User?> getUser() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/user'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // News
  Future<List<News>> getNews() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/news'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => News.fromJson(e)).toList();
    }
    return [];
  }

  Future<News?> getNewsById(int id) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/news/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return News.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<String?> createNews(String title, String content, XFile? image) async {
    final uri = Uri.parse('${Config.baseUrl}/news');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _getHeaders());
    request.fields['title'] = title;
    request.fields['content'] = content;

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image_url',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'), // Adjust if needed
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('image_url', image.path));
      }
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      debugPrint('Create News Response: $respStr');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Check if body contains specific error even with 200 OK (sometimes happens)
        if (respStr.contains("The POST data is too large")) {
          return "Image is too large. Please upload an image smaller than 2MB.";
        }
        return null; // Success
      } else {
        if (respStr.contains("The POST data is too large")) {
          return "Image is too large. Please upload an image smaller than 2MB.";
        }
        return "Failed to create news: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String?> updateNews(
      int id, String title, String content, XFile? image) async {
    // For update, we might need to use _method=PUT if using MultipartRequest with Laravel sometimes
    // But standard POST with _method field is safer for Multipart
    final uri = Uri.parse('${Config.baseUrl}/news/$id');
    final request =
        http.MultipartRequest('POST', uri); // Use POST for multipart
    request.headers.addAll(await _getHeaders());
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['_method'] = 'PUT'; // Laravel trick for PUT with Multipart

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image_url',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('image_url', image.path));
      }
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      debugPrint('Update News Response: $respStr');

      if (response.statusCode == 200) {
        if (respStr.contains("The POST data is too large")) {
          return "Image is too large. Please upload an image smaller than 2MB.";
        }
        return null; // Success
      } else {
        if (respStr.contains("The POST data is too large")) {
          return "Image is too large. Please upload an image smaller than 2MB.";
        }
        return "Failed to update news: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<bool> deleteNews(int id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/news/$id'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // Comments
  Future<List<Comment>> getComments(int newsId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/news/$newsId/comments'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Comment.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createComment(int newsId, String content) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/news/$newsId/comments'),
      headers: await _getHeaders(),
      body: jsonEncode({'content': content}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/comments/$commentId'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }
}
