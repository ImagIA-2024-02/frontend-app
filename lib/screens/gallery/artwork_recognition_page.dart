// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ArtworkRecognitionPage extends StatefulWidget {
  const ArtworkRecognitionPage({super.key});

  @override
  _ArtworkRecognitionPageState createState() => _ArtworkRecognitionPageState();
}

class _ArtworkRecognitionPageState extends State<ArtworkRecognitionPage> {
  Interpreter? _interpreter;
  String _result = "Resultado: Desconocido";
  File? _imageFile;
  bool _isModelLoaded = false;
  String _status = "Cargando modelo...";

  final List<String> correctOrderAuthors = [
    "Claude Monet", 
    "Leonardo Da Vinci", 
    "Pablo Picasso", 
    "Salvador Dali", 
    "Van Gogh"
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Descargar el modelo desde Firebase Machine Learning
      final model = await FirebaseModelDownloader.instance.getModel(
        "image_recognition",
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      // Cargar el modelo usando tflite_flutter
      final interpreter = Interpreter.fromFile(model.file);

      setState(() {
        _interpreter = interpreter;
        _isModelLoaded = true;
        _status = "Modelo cargado correctamente.";
      });
      print("Modelo cargado exitosamente");
    } catch (e) {
      setState(() {
        _status = "Error al cargar el modelo: $e";
      });
      print("Error al cargar el modelo: $e");
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona el origen de la imagen"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text("Cámara"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text("Galería"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _runModelOnImage(_imageFile!);
    }
  }

  Future<void> _runModelOnImage(File image) async {
    if (_interpreter == null) return;

    // Leer la imagen y convertirla en un formato adecuado para el modelo
    img.Image? inputImage = img.decodeImage(await image.readAsBytes());
    if (inputImage == null) return;

    // Redimensionar la imagen a 224x224 (tamaño esperado)
    img.Image resizedImage = img.copyResize(inputImage, width: 224, height: 224);

    // Convertir la imagen en un tensor de entrada [1, 224, 224, 3]
    var input = List.generate(224 * 224 * 3, (i) => 0.0).reshape([1, 224, 224, 3]);
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;  // Componente rojo
        input[0][y][x][1] = pixel.g / 255.0;  // Componente verde
        input[0][y][x][2] = pixel.b / 255.0;  // Componente azul
      }
    }

    // Definir el tensor de salida para el modelo
    var output = List.filled(5, 0.0).reshape([1, 5]);

    // Ejecutar el modelo en la imagen
    _interpreter!.run(input, output);

    // Convert output to a list of doubles and find the index of the highest value
    List<double> outputList = List<double>.from(output[0]);
    int predictedIndex = outputList.indexWhere((element) => element == outputList.reduce((a, b) => a > b ? a : b));

    // Map the index to the corresponding author
    String recognizedAuthor = correctOrderAuthors[predictedIndex];

    setState(() {
      _result = "Resultado: $recognizedAuthor";
    });
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
        title: const Text("Reconocimiento de Autor"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isModelLoaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _imageFile == null
                      ? const Text("Seleccione una imagen")
                      : Image.file(_imageFile!, height: 200),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showImageSourceDialog,
                    child: const Text("Seleccionar Imagen"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
