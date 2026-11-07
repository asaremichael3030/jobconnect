import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/company_profile.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class CompanyResult {
  final bool success;
  final String? message;
  final bool exists;
  final CompanyProfile? company;

  CompanyResult({
    required this.success,
    this.message,
    this.exists = false,
    this.company,
  });
}

class CompanyService {
  CompanyService._();

  static Future<CompanyResult> fetchMyCompany() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return CompanyResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(ApiConstants.companyMe, token: token);

    if (!response.success) {
      return CompanyResult(
        success: false,
        message: response.message ?? 'Failed to load company',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final exists = data['exists'] == true;

    if (!exists) {
      return CompanyResult(success: true, exists: false);
    }

    final companyJson = data['company'] as Map<String, dynamic>;
    return CompanyResult(
      success: true,
      exists: true,
      company: CompanyProfile.fromJson(companyJson),
    );
  }

  static Future<CompanyResult> updateMyCompany(
    Map<String, dynamic> fields,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return CompanyResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.put(
      ApiConstants.companyMe,
      fields,
      token: token,
    );

    if (!response.success) {
      return CompanyResult(
        success: false,
        message: response.message ?? 'Failed to update company',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final companyJson = data['company'] as Map<String, dynamic>?;

    if (companyJson == null) {
      return CompanyResult(success: true, exists: false);
    }

    return CompanyResult(
      success: true,
      exists: true,
      company: CompanyProfile.fromJson(companyJson),
    );
  }

  static Future<CompanyResult> uploadCompanyLogo(
    List<int> bytes,
    String filename,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return CompanyResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.companyMe}/logo',
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
        return CompanyResult(
          success: false,
          message: 'Server returned an invalid response',
        );
      }

      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return CompanyResult(success: true);
      }

      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      return CompanyResult(
        success: false,
        message: message ?? 'Upload failed',
      );
    } catch (error) {
      return CompanyResult(
        success: false,
        message: 'Could not reach the server. Is it running?',
      );
    }
  }
}