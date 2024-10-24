import 'package:dio/dio.dart';

class ProfileService {
  final String baseUrl;
  final Dio dio;

  ProfileService({this.baseUrl = "http://127.0.0.1:8000/api"}) : dio = Dio();

  // Fetch user information


  // Create a new user profile
  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await dio.post(
        '$baseUrl/profiles/',
        data: profileData,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create profile: ${e.response?.statusCode}');
    }
  }

  // Update an existing user profile
  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await dio.put(
        '$baseUrl/profiles/$userId/',
        data: profileData,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.response?.statusCode}');
    }
  }

  // Delete a user profile by ID
  Future<void> deleteProfile(String userId) async {
    try {
      await dio.delete('$baseUrl/profiles/$userId/');
    } on DioException catch (e) {
      throw Exception('Failed to delete profile: ${e.response?.statusCode}');
    }
  }
}
