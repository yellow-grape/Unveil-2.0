import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;
  final Dio dio;

  AuthService({this.baseUrl = "http://127.0.0.1:8000/api"}) : dio = Dio();

  /// Register a new user
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData, String email) async {
    final response = await _postRequest('/Auth/register/', userData);
    return _parseSingleResponse(response);
  }

  /// Login a user
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final response = await _postRequest('/Auth/login/', credentials);
    final token = response.data['token']; // Assuming the token is returned in the response
    await _storeToken(token); // Store the token after successful login
    return _parseSingleResponse(response);
  }

  /// Logout the user
  Future<void> logout() async {
    final token = await _getToken(); // Get the stored token
    await _deleteRequest('/auth/logout/', token!);
    await _removeToken(); // Remove the token after logout
  }

  /// Get the current user's ID
  Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      final token = await _getToken(); // Get the stored token
      final response = await dio.get('$baseUrl/Auth/user/', options: Options(
        headers: {
          'Authorization': 'Bearer $token', // Set the token in the header
        },
      ));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        print('Failed to load user info: ${response.statusCode}');
        return {};
      }
    } on DioException catch (e) {
      throw Exception('Failed to load user info: ${e.response?.statusCode}');
    }
  }

  // Private Methods for HTTP Requests
  Future<Response> _getRequest(String path, String token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      return await dio.get('$baseUrl$path');
    } on DioException catch (e) {
      _handleError(e);
    }
    throw Exception('Failed to perform GET request');
  }

  Future<Response> _postRequest(String path, Map<String, dynamic> data) async {
    try {
      return await dio.post('$baseUrl$path', data: data);
    } on DioException catch (e) {
      _handleError(e);
    }
    throw Exception('Failed to perform POST request');
  }

  Future<void> _deleteRequest(String path, String token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      await dio.delete('$baseUrl$path');
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Token Storage Methods
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Parsing Methods
  Map<String, dynamic> _parseSingleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(response.data);
    }
    throw Exception('Failed to load data');
  }

  // Error Handling
  void _handleError(DioException e) {
    final errorMessage = e.response != null
        ? 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}'
        : 'Network error: ${e.message}';
    throw Exception(errorMessage);
  }
}
