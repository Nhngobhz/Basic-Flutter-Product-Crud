import 'api_service.dart';

class AuthService {
  // POST /api/auth/signup
  static Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    await ApiService.post('/api/auth/signup', {
      'name': username,
      'email': email,
      'password': password,
    });
  }

  // POST /api/auth/login  → saves token to SharedPreferences
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String?;
    if (token == null) throw ApiException('No token received from server');
    await ApiService.saveToken(token);
  }

  // POST /api/auth/forgot-password
  static Future<void> forgotPassword({required String email}) async {
    await ApiService.post('/api/auth/forgot-password', {'email': email});
  }

  // POST /api/auth/reset-password
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await ApiService.post('/api/auth/reset-password', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/api/auth/logout', {});
    } catch (_) {
      // even if backend fails, continue clearing locally
    }

    await ApiService.clearToken();
  }
}
