import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:lottie/lottie.dart';

import 'artwork_delimiter.dart';

class ImageRestorationModel extends StatefulWidget {
  const ImageRestorationModel({super.key});

  @override
  _ImageRestorationModelState createState() => _ImageRestorationModelState();
}

class _ImageRestorationModelState extends State<ImageRestorationModel> {
  Interpreter? _interpreter;
  Uint8List? _selectedImageBytes;
  Uint8List? _restoredImageBytes;
  bool _isLoadingModel = true;
  bool _isRestoring = false;

  final ArtworkDelimiter artworkDelimiter = ArtworkDelimiter();

  @override
  void initState() {
    super.initState();
    _initializeModels();
  }

  Future<void> _initializeModels() async {
    setState(() {
      _isLoadingModel = true;
    });

    await Firebase.initializeApp();

    try {
      await artworkDelimiter.initialize("artwork_delimiter");
      final model = await FirebaseModelDownloader.instance.getModel(
        "RestorationModelV2",
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );
      _interpreter = Interpreter.fromFile(File(model.file.path));
      _interpreter?.allocateTensors();
    } catch (e) {
      print("Error loading models: $e");
    } finally {
      setState(() {
        _isLoadingModel = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImageBytes = imageBytes;
        _isRestoring = true;
      });

      try {
        Uint8List croppedImage = await compute(_cropImage, imageBytes);

        await _runModel(croppedImage);
      } catch (e) {
        print("Error during image processing: $e");
      } finally {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    if (_interpreter == null) return;

    try {
      await Future.delayed(const Duration(seconds: 2));
      final input = await compute(_preprocessImage, imageBytes);
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      final outputBuffer = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.generate(
            outputShape[2],
            (_) => List.filled(outputShape[3], 0.0),
          ),
        ),
      );

      _interpreter!.run(input.buffer.asUint8List(), outputBuffer);

      final restoredImage = await compute(_postProcessOutput, outputBuffer);

      setState(() {
        _restoredImageBytes = restoredImage;
      });
    } catch (e) {
      print("Error during inference: $e");
    }
  }

  static Uint8List _cropImage(Uint8List imageBytes) {
    // Simulate cropping or return original image if no cropping is implemented
    return imageBytes;
  }

  static Float32List _preprocessImage(Uint8List imageBytes) {
    final image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");

    final image_lib.Image resizedImage =
        image_lib.copyResize(image, width: 256, height: 256);

    final Float32List input = Float32List(256 * 256 * 3);
    int index = 0;

    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }

    return input;
  }

  static Uint8List _postProcessOutput(List<dynamic> outputBuffer) {
    final int height = outputBuffer[0].length;
    final int width = outputBuffer[0][0].length;
    final image_lib.Image restoredImage =
        image_lib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final r = (outputBuffer[0][y][x][0] * 255).toInt().clamp(0, 255);
        final g = (outputBuffer[0][y][x][1] * 255).toInt().clamp(0, 255);
        final b = (outputBuffer[0][y][x][2] * 255).toInt().clamp(0, 255);

        restoredImage.setPixel(x, y, image_lib.ColorRgb8(r, g, b));
      }
    }

    return Uint8List.fromList(image_lib.encodePng(restoredImage));
  }

  Future<void> _saveToGallery() async {
    if (_restoredImageBytes == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final storageRef = FirebaseStorage.instance.ref().child(
          'user-gallery/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putData(_restoredImageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen guardada en la galería')),
      );

      GoRouter.of(context).go('/gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restauración de Imágenes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFFA8072),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9F6), Color(0xFFFFD6C2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoadingModel)
                Center(
                  child: Lottie.asset('assets/animations/downloading.json'),
                )
              else if (_selectedImageBytes != null)
                Card(
                  color: const Color(0xFFF7ECEA),
                  child: Column(
                    children: [
                      const Text("Imagen Seleccionada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Image.memory(_selectedImageBytes!,
                          width: 256, height: 256),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              if (_isRestoring)
                Lottie.asset('assets/animations/loding-restoration.json'),
              if (_restoredImageBytes != null)
                Card(
                  color: const Color(0xFFF7ECEA),
                  child: Column(
                    children: [
                      const Text("Imagen Restaurada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Image.memory(_restoredImageBytes!,
                          width: 256, height: 256),
                      ElevatedButton(
                        onPressed: _saveToGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA8072),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        child: const Text("Guardar en Galería", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA8072),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Elegir de la Galería",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA8072),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Capturar Foto",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
