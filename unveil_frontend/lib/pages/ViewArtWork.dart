import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Ensure you have the Dio package imported
import 'package:unveil_frontend/services/Artworkservice.dart';

class ViewArt extends StatefulWidget {
  const ViewArt({Key? key}) : super(key: key);

  @override
  _ViewArtState createState() => _ViewArtState();
}

class _ViewArtState extends State<ViewArt> {
  final ArtworkService artworkService = ArtworkService(baseUrl: 'http://127.0.0.1:8000/api'); // Replace with your base URL
  final String iss = 'http://127.0.0.1:8000/';
  List<Map<String, dynamic>> artworks = [];
  int currentIndex = 0;
  bool liked = false;
  bool disliked = false;

  // Current user ID (replace with your logic to get the current user's ID)
  final int currentUserId = 1; 

  @override
  void initState() {
    super.initState();
    _fetchArtworks();
  }

  // Fetch artworks and filter those not created by the current user
  Future<void> _fetchArtworks() async {
    try {
      List<Map<String, dynamic>> allArtworks = await artworkService.fetchArtworks();
      // Filter artworks that are not created by the current user
      artworks = allArtworks.where((artwork) => artwork['user_id'] != currentUserId).toList();
      setState(() {}); // Update UI after fetching artworks
    } catch (e) {
      // Handle errors, e.g., show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching artworks: $e')),
      );
    }
  }

  // Method to go to the next artwork
  void _nextArtwork() {
    setState(() {
      currentIndex = (currentIndex + 1) % artworks.length; // Loop back to start
      liked = false; // Reset likes and dislikes when changing artwork
      disliked = false;
    });
  }

  // Method to go to the previous artwork
  void _previousArtwork() {
    setState(() {
      currentIndex = (currentIndex - 1 + artworks.length) % artworks.length; // Loop back to end
      liked = false; // Reset likes and dislikes when changing artwork
      disliked = false;
    });
  }

  // Toggle the like status
  void _toggleLike() {
    setState(() {
      liked = !liked; // Toggle like
      if (liked) disliked = false; // Disable dislike if liked
    });
  }

  // Toggle the dislike status
  void _toggleDislike() {
    setState(() {
      disliked = !disliked; // Toggle dislike
      if (disliked) liked = false; // Disable like if disliked
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: artworks.isEmpty // Check if artworks are loaded
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left side button for Previous
                          GestureDetector(
                            onTap: _previousArtwork,
                            child: Container(
                              width: 80,
                              height: isMobile ? width * 0.7 : 600,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.arrow_back_ios,
                                size: 50,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Image container
                          Container(
                            width: isMobile ? width * 0.8 : 500,
                            height: isMobile ? width * 0.7 : 600,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Image.network(
                              
  '${iss}${artworks[currentIndex]['image']}', // Combine base URL with relative path
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {  
                                return Center(
                                  child: Text(
  '${artworkService.baseUrl}${artworks[currentIndex]['image']}', // Combine base URL with relative path
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Right side button for Next
                          GestureDetector(
                            onTap: _nextArtwork,
                            child: Container(
                              width: 80,
                              height: isMobile ? width * 0.7 : 600,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 50,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                        child: Text(
                          artworks[currentIndex]['title'], // Dynamic title
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                        child: Text(
                          artworks[currentIndex]['description'], // Dynamic description
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Like and Dislike buttons with toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Like button
                          IconButton(
                            onPressed: _toggleLike,
                            icon: Icon(
                              Icons.thumb_up,
                              color: liked ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 30),
                          // Dislike button
                          IconButton(
                            onPressed: _toggleDislike,
                            icon: Icon(
                              Icons.thumb_down,
                              color: disliked ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
