import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:unveil_frontend/services/Artworkservice.dart';
import 'package:unveil_frontend/services/AuthService.dart';
import 'dart:io'; // Import dart:io to use File

class UploadArt extends StatefulWidget {
  const UploadArt({Key? key}) : super(key: key);

  @override
  _UploadArtState createState() => _UploadArtState();
}

class _UploadArtState extends State<UploadArt> {
  final ArtworkService ars = ArtworkService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _imageBytes; // Store image bytes
  String? _imageName; // Store the image name
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
Future<void> _pickImage() async {
  try {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false, // Allow only single file selection
    );

    if (picked != null && picked.files.isNotEmpty) {
      setState(() {
        _imageBytes = picked.files.first.bytes; // Store bytes directly
        _imageName = picked.files.first.name; // Store the image name
      });
    } else {
      // Handle the case when no file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
    }
  } catch (error) {
    // Handle any error that may occur during the file picking process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking file: $error')),
    );
  }
}
  Future<void> _uploadArtwork() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    final authToken = await AuthService().getToken();
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final artworkData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageName': _imageName, // Include the image name
    };

    try {
      // Convert Uint8List to File
      final imageFile = await _convertBytesToFile(_imageBytes!, _imageName!);

      // Now pass the File instead of Uint8List
      await ars.createArtwork(artworkData, imageFile, authToken);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artwork uploaded successfully!')),
      );
      _resetForm();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload artwork: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Convert Uint8List to File
  Future<File> _convertBytesToFile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _imageBytes = null;
      _imageName = null; // Reset the image name
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Upload Artwork')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField('Artwork Title', 'Enter artwork title', _titleController),
              const SizedBox(height: 20),
              _buildTextField('Artwork Description', 'Enter artwork description', _descriptionController, maxLines: 4),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                  color: Colors.grey[300],
                  child: _imageBytes == null
                      ? const Center(child: Text('Tap to select an image'))
                      : Image.memory(_imageBytes!, fit: BoxFit.cover), // Use Image.memory to display the image
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
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

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
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
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }
}
