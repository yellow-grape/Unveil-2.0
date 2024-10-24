import 'package:dio/dio.dart';

class ArtworkService {
  final String baseUrl;
  final Dio dio;

  ArtworkService({this.baseUrl = "http://127.0.0.1:8000/api"}) : dio = Dio();

  // Fetch all artworks
  Future<List<Map<String, dynamic>>> fetchArtworks() async {
    try {
      final response = await dio.get('$baseUrl/Artwork/artwork/'); // Updated endpoint to match the case
      if (response.statusCode == 200) {
        // Map the JSON response to a list of artworks
        List<dynamic> artworks = response.data;
        return artworks.map((artwork) => {
          'id': artwork['id'],
          'author': artwork['author'],
          'image': artwork['ArtWork'],  // Use 'ArtWork' key to get image URL
          'title': artwork['title'],
          'description': artwork['description'],
          'createdAt': artwork['created_at'],
          
        }).toList();
      } else {
        print('Failed to load artworks: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Create a new artwork
  Future<Map<String, dynamic>> createArtwork(Map<String, dynamic> artworkData) async {
    try {
      final response = await dio.post(
        '$baseUrl/artwork/', // Ensure this URL is correct
        data: artworkData,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      throw Exception('Failed to create artwork: ${e.response?.statusCode}');
    }
  }

  // Fetch a single artwork by ID
  Future<Map<String, dynamic>> fetchArtwork(int artworkId) async {
    try {
      final response = await dio.get('$baseUrl/Artwork/$artworkId/'); // Ensure this URL is correct
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load artwork: ${e.response?.statusCode}');
    }
  }

  // Update an existing artwork
  Future<Map<String, dynamic>> updateArtwork(int artworkId, Map<String, dynamic> artworkData) async {
    try {
      final response = await dio.put(
        '$baseUrl/Artwork/$artworkId/', // Ensure this URL is correct
        data: artworkData,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      throw Exception('Failed to update artwork: ${e.response?.statusCode}');
    }
  }

  // Delete an artwork by ID
  Future<void> deleteArtwork(int artworkId) async {
    try {
      await dio.delete('$baseUrl/Artwork/$artworkId/'); // Ensure this URL is correct
    } on DioError catch (e) {
      throw Exception('Failed to delete artwork: ${e.response?.statusCode}');
    }
  }
}
