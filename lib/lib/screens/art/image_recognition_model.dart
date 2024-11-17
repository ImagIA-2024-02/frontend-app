import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:lottie/lottie.dart';

class ImageRecognitionModel extends StatefulWidget {
  const ImageRecognitionModel({super.key});

  @override
  _ImageRecognitionModelState createState() => _ImageRecognitionModelState();
}

class _ImageRecognitionModelState extends State<ImageRecognitionModel> {
  Interpreter? _interpreter;
  Uint8List? _selectedImageBytes;
  String? _predictedLabel;
  double? _confidence;
  bool _isLoadingModel = true;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoadingModel = true;
    });

    await Firebase.initializeApp();

    try {
      final model = await FirebaseModelDownloader.instance.getModel(
        "modelo_reconocimiento_autor_v2",
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );
      _interpreter = Interpreter.fromFile(File(model.file.path));
      _interpreter?.allocateTensors();
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
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
        _isProcessingImage = true;
      });

      await _runModel(imageBytes);
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    if (_interpreter == null) {
      print("Interpreter is not initialized.");
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      final Float32List input = _preprocessImage(imageBytes);
      final outputBuffer = Float32List(_interpreter!.getOutputTensor(0).shape.reduce((a, b) => a * b));

      _interpreter!.run(input.buffer.asUint8List(), outputBuffer.buffer.asUint8List());

      final predictedClass = outputBuffer.indexWhere((e) => e == outputBuffer.reduce((a, b) => a > b ? a : b));
      final confidence = outputBuffer[predictedClass];
      final label = confidence < 0.75 ? "Desconocido" : _mapClassToLabel(predictedClass);

      setState(() {
        _predictedLabel = label;
        _confidence = confidence;
        _isProcessingImage = false;
      });

    } catch (e) {
      print("Error during inference: $e");
    }
  }

  Float32List _preprocessImage(Uint8List imageBytes) {
    final img_lib.Image? image = img_lib.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");

    final img_lib.Image resizedImage = img_lib.copyResize(image, width: 224, height: 224);
    final Float32List input = Float32List(224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }

    return input;
  }

  String _mapClassToLabel(int classIndex) {
    const labels = [
      "Claude Monet",
      "Frida Kahlo",
      "Leonardo Da Vinci",
      "Pablo Picasso",
      "Salvador Dali",
      "Vincent Van Gogh",
    ];
    return labels[classIndex];
  }

  Future<void> _saveToGallery() async {
    if (_selectedImageBytes == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final storageRef = FirebaseStorage.instance.ref().child(
          'user-gallery/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putData(_selectedImageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery successfully')),
      );

      GoRouter.of(context).go('/gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reconocimiento de Autor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFFA8072), // Coral
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9F6), Color(0xFFFFD6C2)], // Light beige to coral
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
                Center(child: Lottie.asset('assets/animations/downloading-infinite.json'))
              else ...[
                if (_selectedImageBytes != null)
                  Card(
                    color: const Color(0xFFF7ECEA),
                    child: Column(
                      children: [
                        const Text("Imagen Seleccionada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        Image.memory(_selectedImageBytes!, width: 224, height: 224),
                      ],
                    ),
                  ),
                if (_isProcessingImage)
                  Lottie.asset('assets/animations/loding-restoration.json'),
                if (!_isProcessingImage && _predictedLabel != null)
                  Card(
                    color: const Color(0xFFF7ECEA),
                    child: Column(
                      children: [
                        Text("Autor: $_predictedLabel", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("confianza: ${(_confidence! * 100).toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA8072),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text("Elegir imagen de la galería", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA8072),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text("Capturar foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
