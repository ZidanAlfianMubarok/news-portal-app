import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.login(email, password);
      if (success) {
        await getUser();
      }
      return success;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password,
      String passwordConfirmation) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.register(
          name, email, password, passwordConfirmation);
      if (success) {
        await getUser();
      }
      return success;
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> getUser() async {
    try {
      _user = await _apiService.getUser();
    } catch (e) {
      debugPrint('GetUser Error: $e');
    }
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _apiService.getToken();
    if (token != null) {
      await getUser();
      return true;
    }
    return false;
  }
}
