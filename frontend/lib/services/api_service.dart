import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ApiService {
  ApiService._();

  static Future<ApiResponse> get(String path, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(token),
      );
      return _parse(response);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Could not reach the server. Is it running?',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _parse(response);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Could not reach the server. Is it running?',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _parse(response);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Could not reach the server. Is it running?',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> patch(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _parse(response);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Could not reach the server. Is it running?',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> delete(String path, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(token),
      );
      return _parse(response);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Could not reach the server. Is it running?',
        statusCode: 0,
      );
    }
  }

  static Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static ApiResponse _parse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Server returned an invalid response',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return ApiResponse(
        success: decoded['success'] == true,
        data: decoded['data'],
        message: decoded['message'] as String?,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: 'Unexpected response format',
      statusCode: response.statusCode,
    );
  }
}