import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'api_service.dart';

class AuthResult {
  final bool success;
  final String? message;
  final String? role;
  final String? name;
  final int? userId;

  AuthResult({
    required this.success,
    this.message,
    this.role,
    this.name,
    this.userId,
  });
}

class AuthService {
  AuthService._();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';
  static const String _nameKey = 'auth_name';
  static const String _userIdKey = 'auth_user_id';

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await ApiService.post(ApiConstants.register, {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });

    if (!response.success) {
      return AuthResult(success: false, message: response.message);
    }

    return AuthResult(success: true);
  }

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(ApiConstants.login, {
      'email': email,
      'password': password,
    });

    if (!response.success) {
      return AuthResult(success: false, message: response.message);
    }

    final data = response.data as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final role = user['role'] as String;
    final name = user['name'] as String;
    final userId = user['id'] as int;

    await _saveSession(
      token: token,
      role: role,
      name: name,
      userId: userId,
    );

    return AuthResult(
      success: true,
      role: role,
      name: name,
      userId: userId,
    );
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  static Future<AuthResult> restoreSession() async {
    final token = await _readToken();
    if (token == null) {
      return AuthResult(success: false);
    }

    final response = await ApiService.get(ApiConstants.me, token: token);
    if (!response.success) {
      await logout();
      return AuthResult(success: false);
    }

    final data = response.data as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    final role = user['role'] as String;
    final name = user['name'] as String;
    final userId = user['id'] as int;

    await _saveSession(
      token: token,
      role: role,
      name: name,
      userId: userId,
    );

    return AuthResult(
      success: true,
      role: role,
      name: name,
      userId: userId,
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_userIdKey);
  }

  static Future<String?> readToken() => _readToken();

  static Future<String?> readRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveSession({
    required String token,
    required String role,
    required String name,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_nameKey, name);
    await prefs.setInt(_userIdKey, userId);
  }
}