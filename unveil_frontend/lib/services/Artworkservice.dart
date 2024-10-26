import 'dart:io';
import 'package:dio/dio.dart';

class ArtworkService {
  final String baseUrl;
  final Dio dio;

  ArtworkService({this.baseUrl = "http://127.0.0.1:8000/api"}) : dio = Dio();

  // Fetch all artworks
  Future<List<Map<String, dynamic>>> fetchArtworks() async {
    try {
      final response = await dio.get('$baseUrl/Artwork/artwork/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data.map((artwork) => {
          'id': artwork['id'],
          'author': artwork['author'],
          'image': artwork['artwork_image'],
          'title': artwork['title'],
          'description': artwork['description'],
          'createdAt': artwork['created_at'],
        }));
      } else {
        print("Error fetching artworks: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching artworks: $e");
    }
    return [];
  }

  // Create artwork with image upload
  Future<Map<String, dynamic>> createArtwork(
      Map<String, dynamic> artworkData, File imageFile, String authToken) async {
    try {
      var formData = FormData.fromMap({
        'title': artworkData['title'],
        'description': artworkData['description'],
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '$baseUrl/Artwork/artwork/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        print("Failed to create artwork: ${response.statusCode}");
        throw Exception('Failed to create artwork');
      }
    } on DioError catch (e) {
      print("Failed to create artwork: ${e.response?.statusCode} ${e.response?.data}");
      throw Exception('Failed to create artwork: ${e.message}');
    }
  }

  // Fetch a single artwork by ID
  Future<Map<String, dynamic>> fetchArtwork(int artworkId) async {
    try {
      final response = await dio.get('$baseUrl/Artwork/$artworkId/');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        print("Failed to load artwork: ${response.statusCode}");
        throw Exception('Failed to load artwork');
      }
    } on DioError catch (e) {
      print("Failed to load artwork: ${e.response?.statusCode}");
      throw Exception('Failed to load artwork: ${e.message}');
    }
  }

  // Update artwork
  Future<Map<String, dynamic>> updateArtwork(int artworkId, Map<String, dynamic> artworkData) async {
    try {
      final response = await dio.put(
        '$baseUrl/Artwork/$artworkId/',
        data: artworkData,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        print("Failed to update artwork: ${response.statusCode}");
        throw Exception('Failed to update artwork');
      }
    } on DioError catch (e) {
      print("Failed to update artwork: ${e.response?.statusCode}");
      throw Exception('Failed to update artwork: ${e.message}');
    }
  }

  // Delete artwork by ID
  Future<void> deleteArtwork(int artworkId) async {
    try {
      final response = await dio.delete('$baseUrl/Artwork/$artworkId/');
      if (response.statusCode != 204) {
        print("Failed to delete artwork: ${response.statusCode}");
        throw Exception('Failed to delete artwork');
      }
    } on DioError catch (e) {
      print("Failed to delete artwork: ${e.response?.statusCode}");
      throw Exception('Failed to delete artwork: ${e.message}');
    }
  }
}
