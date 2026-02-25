import 'dart:convert';
import 'dart:io';
import 'package:frontend/api/api_base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static final String baseUrl = ApiBaseUrl.baseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  // ─── Token helpers ────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ─── Base headers ─────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Response parser ─────────────────────────────────────────────────────

  static dynamic _parse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final msg = body['message'] ?? body['error'] ?? 'Something went wrong';
    throw ApiException(msg, statusCode: response.statusCode);
  }

  // ─── HTTP verbs ───────────────────────────────────────────────────────────

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException {
      throw ApiException('No internet connection. Is the server running?');
    } on HttpException {
      throw ApiException('Network error. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<dynamic> get(String path, {bool auth = true}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _parse(response);
    } on SocketException {
      throw ApiException('No internet connection. Is the server running?');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<dynamic> put(
    String path,
    Map<String, dynamic> data, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException {
      throw ApiException('No internet connection. Is the server running?');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException {
      throw ApiException('No internet connection. Is the server running?');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
}
