import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ProfileResult {
  final bool success;
  final String? message;
  final UserProfile? profile;

  ProfileResult({required this.success, this.message, this.profile});
}

class UserService {
  UserService._();

  static Future<ProfileResult> fetchMyProfile() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ProfileResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(ApiConstants.userMe, token: token);

    if (!response.success) {
      return ProfileResult(
        success: false,
        message: response.message ?? 'Failed to load profile',
      );
    }

    final data = response.data as Map<String, dynamic>;
    return ProfileResult(
      success: true,
      profile: UserProfile.fromJson(data),
    );
  }

  static Future<ProfileResult> updateMyProfile(
    Map<String, dynamic> fields,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ProfileResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.put(
      ApiConstants.userMe,
      fields,
      token: token,
    );

    if (!response.success) {
      return ProfileResult(
        success: false,
        message: response.message ?? 'Failed to update profile',
      );
    }

    return ProfileResult(success: true);
  }

  static Future<ProfileResult> uploadProfilePicture(
    List<int> bytes,
    String filename,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ProfileResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userMe}/profile-picture',
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return ProfileResult(
          success: false,
          message: 'Server returned an invalid response',
        );
      }

      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return ProfileResult(success: true);
      }

      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      return ProfileResult(
        success: false,
        message: message ?? 'Upload failed',
      );
    } catch (error) {
      return ProfileResult(
        success: false,
        message: 'Could not reach the server. Is it running?',
      );
    }
  }

  static Future<ProfileResult> uploadResume(
    List<int> bytes,
    String filename,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ProfileResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userMe}/resume',
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return ProfileResult(
          success: false,
          message: 'Server returned an invalid response',
        );
      }

      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return ProfileResult(success: true);
      }

      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      return ProfileResult(
        success: false,
        message: message ?? 'Upload failed',
      );
    } catch (error) {
      return ProfileResult(
        success: false,
        message: 'Could not reach the server. Is it running?',
      );
    }
  }

  static Future<bool> addSkill(String skill) async {
    final token = await AuthService.readToken();
    if (token == null) return false;
    
    final res = await ApiService.post(
      '${ApiConstants.userMe}/skills', 
      {'skill': skill}, 
      token: token,
    );
    return res.success;
  }

  static Future<bool> addExperience({
    required String jobTitle,
    required String company,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    final token = await AuthService.readToken();
    if (token == null) return false;
    
    final res = await ApiService.post(
      '${ApiConstants.userMe}/experience', 
      {
        'jobTitle': jobTitle, 
        'company': company, 
        'startDate': startDate, 
        'endDate': endDate, 
        'description': description,
      }, 
      token: token,
    );
    return res.success;
  }

  static Future<bool> addEducation({
    required String degree,
    required String school,
    required int startYear,
    required int endYear,
  }) async {
    final token = await AuthService.readToken();
    if (token == null) return false;
    
    final res = await ApiService.post(
      '${ApiConstants.userMe}/education', 
      {
        'degree': degree, 
        'school': school, 
        'startYear': startYear, 
        'endYear': endYear,
      }, 
      token: token,
    );
    return res.success;
  }
}