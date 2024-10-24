import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadArt extends StatefulWidget {
  const UploadArt({super.key});

  @override
  _UploadArtState createState() => _UploadArtState();
}

class _UploadArtState extends State<UploadArt> {
  XFile? _image; // To hold the selected image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _image = selectedImage; // Store the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Set the width of the text fields
    final textFieldWidth = MediaQuery.of(context).size.width > 600 ? 350.0 : double.infinity; // Adjusted width

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Upload Artwork')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField('Artwork Title', 'Enter artwork title', textFieldWidth),
              const SizedBox(height: 20),
              _buildTextField('Artwork Description', 'Enter artwork description', textFieldWidth, maxLines: 4),
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
                onTap: _pickImage, // Trigger image picker on tap
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _image == null
                      ? const Center(child: Text('Tap to select an image'))
                      : Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _minimalistButton(
                label: 'Upload',
                onPressed: () {
                  // Handle upload action
                },
                color: isDarkMode ? Colors.white : Colors.black,
                textColor: isDarkMode ? Colors.black : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, double width, {int maxLines = 1}) {
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
          textAlign: TextAlign.center, // Center align the label
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          child: TextField(
            maxLines: maxLines,
            textAlign: TextAlign.center, // Center align the text inside the field
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
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
