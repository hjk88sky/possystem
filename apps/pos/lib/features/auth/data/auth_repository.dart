import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());
    final data = response.data['data'] ?? response.data;
    final loginResponse = LoginResponse.fromJson(data);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', loginResponse.accessToken);
    await prefs.setString('refresh_token', loginResponse.refreshToken);

    return loginResponse;
  }

  Future<User> me() async {
    final response = await _dio.get('/auth/me');
    final data = response.data['data'] ?? response.data;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Ignore logout API errors
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    }
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
