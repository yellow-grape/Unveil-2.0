import 'dart:html' as html; // Ensure this is imported
import 'package:flutter/material.dart';
import 'package:unveil_frontend/services/Artworkservice.dart';
import 'package:unveil_frontend/services/AuthService.dart';

class UploadArt extends StatefulWidget {
  const UploadArt({super.key});

  @override
  _UploadArtState createState() => _UploadArtState();
}

class _UploadArtState extends State<UploadArt> {
  final ars = ArtworkService();

  html.File? _image; // To hold the selected image
  String? _imageUrl; // To display the image
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Accept only image files
    uploadInput.click(); // Open file picker dialog

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _image = files.first;
          _imageUrl = html.Url.createObjectUrl(_image); // Create a URL for the image
        });
      }
    });
  }

  void _uploadArtwork() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _image == null) {
      // Show an error if any field is empty or no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    // Get the authentication token
    final authToken = await AuthService().getToken();
    
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed')),
      );
      return;
    }

    final artworkData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
    };

    try {
      await ars.createArtwork(artworkData, authToken, _image!);
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artwork uploaded successfully!')),
      );
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload artwork: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Set the width of the text fields
    final textFieldWidth = MediaQuery.of(context).size.width > 600 ? 350.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Upload Artwork')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField('Artwork Title', 'Enter artwork title', textFieldWidth, _titleController),
              const SizedBox(height: 20),
              _buildTextField('Artwork Description', 'Enter artwork description', textFieldWidth, _descriptionController, maxLines: 4),
              const SizedBox(height: 20),
              Text(
                'Upload Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 1080, // Set max width to 1080px
                    maxHeight: 1080, // Set max height to 1080px
                  ),
                  color: Colors.grey[300],
                  child: _imageUrl == null
                      ? const Center(child: Text('Tap to select an image'))
                      : Image.network(
                          _imageUrl!,
                          fit: BoxFit.contain, // Ensure the image fits inside the box
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _minimalistButton(
                label: 'Upload',
                onPressed: _uploadArtwork,
                color: isDarkMode ? Colors.white : Colors.black,
                textColor: isDarkMode ? Colors.black : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, double width, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          child: TextField(
            maxLines: maxLines,
            textAlign: TextAlign.center,
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _minimalistButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: textColor,
        ),
      ),
    );
  }
}
