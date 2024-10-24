import 'dart:html' as html; // Ensure this is imported
import 'package:dio/dio.dart';

class ArtworkService {
  final String baseUrl;
  final Dio dio;

  ArtworkService({this.baseUrl = "http://127.0.0.1:8000/api"}) : dio = Dio();

  Future<List<Map<String, dynamic>>> fetchArtworks() async {
    try {
      final response = await dio.get('$baseUrl/Artwork/artwork/');
      if (response.statusCode == 200) {
        List<dynamic> artworks = response.data;
        return artworks.map((artwork) => {
          'id': artwork['id'],
          'author': artwork['author'],
          'image': artwork['artwork_image'],
          'title': artwork['title'],
          'description': artwork['description'],
          'createdAt': artwork['created_at'],
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createArtwork(Map<String, dynamic> artworkData, String authToken, html.File image) async {
    try {
      // Read the image file as bytes
      final reader = html.FileReader();
      reader.readAsArrayBuffer(image);
      
      // Await the reader to finish
      await reader.onLoadEnd.first;

      // Create FormData
      FormData formData = FormData.fromMap({
        'title': artworkData['title'],
        'description': artworkData['description'],
        'image': MultipartFile.fromBytes(reader.result as List<int>, filename: image.name),
      });

      final response = await dio.post(
        '$baseUrl/Artwork/artwork/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      throw Exception('Failed to create artwork: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<Map<String, dynamic>> fetchArtwork(int artworkId) async {
    try {
      final response = await dio.get('$baseUrl/Artwork/$artworkId/');
      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      throw Exception('Failed to load artwork: ${e.response?.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateArtwork(int artworkId, Map<String, dynamic> artworkData) async {
    try {
      final response = await dio.put(
        '$baseUrl/Artwork/$artworkId/',
        data: artworkData,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      throw Exception('Failed to update artwork: ${e.response?.statusCode}');
    }
  }

  Future<void> deleteArtwork(int artworkId) async {
    try {
      await dio.delete('$baseUrl/Artwork/$artworkId/');
    } on DioError catch (e) {
      throw Exception('Failed to delete artwork: ${e.response?.statusCode}');
    }
  }
}
