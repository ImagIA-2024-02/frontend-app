// ignore_for_file: library_private_types_in_public_api

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;

class ArtworkRestorationPage extends StatefulWidget {
  const ArtworkRestorationPage({super.key});

  @override
  _ArtworkRestorationPageState createState() => _ArtworkRestorationPageState();
}

class _ArtworkRestorationPageState extends State<ArtworkRestorationPage> {
  Interpreter? _interpreter;
  Uint8List? _selectedImageBytes;
  Uint8List? _restoredImageBytes;
  bool _isModelLoading = true; // New variable to track model loading state

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        _isModelLoading = true; // Start loading
      });
      final model = await FirebaseModelDownloader.instance.getModel(
        "restoration_image",
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );
      final interpreter = Interpreter.fromFile(model.file);
      setState(() {
        _interpreter = interpreter;
        _isModelLoading = false; // Model is loaded
      });
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
      setState(() {
        _isModelLoading = false; // Stop loading even on failure
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
      });

      if (!_isModelLoading) {
        _runModel(imageBytes);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Model is still loading, please wait.")),
        );
      }
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    if (_interpreter == null) return;

    var input = _preprocessImage(imageBytes);
    var output = List.generate(256 * 256 * 3, (i) => 0.0).reshape([1, 256, 256, 3]);

    _interpreter!.run(input, output);

    setState(() {
      _restoredImageBytes = _postProcessOutput(output);
    });
  }

  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");

    image_lib.Image resizedImage = image_lib.copyResize(image, width: 256, height: 256);

    List<List<List<List<double>>>> input = [
      List.generate(
        256,
        (y) => List.generate(
          256,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            double red = pixel.r / 255.0;
            double green = pixel.g / 255.0;
            double blue = pixel.b / 255.0;
            return [red, green, blue];
          },
        ),
      ),
    ];

    return input;
  }

  Uint8List _postProcessOutput(List<dynamic> output) {
    const int width = 256;
    const int height = 256;
    final image_lib.Image restoredImage = image_lib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final r = (output[0][y][x][0] * 255).toInt();
        final g = (output[0][y][x][1] * 255).toInt();
        final b = (output[0][y][x][2] * 255).toInt();

        final color = image_lib.ColorRgb8(r, g, b);
        restoredImage.setPixel(x, y, color);
      }
    }

    return Uint8List.fromList(image_lib.encodePng(restoredImage));
  }

  Future<void> _saveToGallery() async {
    if (_restoredImageBytes == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final storageRef = FirebaseStorage.instance.ref().child('user-gallery/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putData(_restoredImageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery successfully')),
      );

      GoRouter.of(context).go('/gallery');
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Restoration'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isModelLoading
            ? const CircularProgressIndicator() // Show loader while model loads
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, width: 256, height: 256)
                      : const Text("Select an image"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showImageSourceDialog,
                    child: const Text("Select Image"),
                  ),
                  const SizedBox(height: 20),
                  _restoredImageBytes != null
                      ? Column(
                          children: [
                            const Text("Restored Image"),
                            Image.memory(_restoredImageBytes!, width: 256, height: 256),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _saveToGallery,
                              child: const Text("Save to Gallery"),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
