// ignore_for_file: library_private_types_in_public_api

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
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

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Descargar el modelo desde Firebase Machine Learning
      final model = await FirebaseModelDownloader.instance.getModel(
        "restoration_image",
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      // Cargar el modelo usando tflite_flutter
      final interpreter = Interpreter.fromFile(model.file);

      setState(() {
        _interpreter = interpreter;
      });

      print("Modelo cargado exitosamente");
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
      });
      _runModel(imageBytes);
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    if (_interpreter == null) return;

    // Prepara la imagen de entrada en el formato requerido [1, 256, 256, 3]
    var input = _preprocessImage(imageBytes);
    var output = List.generate(256 * 256 * 3, (i) => 0.0).reshape([1, 256, 256, 3]);

    _interpreter!.run(input, output);

    setState(() {
      // Aquí puedes convertir `output` en `Uint8List` para mostrar la imagen restaurada
      _restoredImageBytes = _postProcessOutput(output);
    });
  }

  // Preprocesa la imagen para adaptarla a la entrada del modelo
  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (image == null) throw Exception("No se pudo decodificar la imagen");

    // Redimensionar a 256x256 y normalizar los valores
    image_lib.Image resizedImage = image_lib.copyResize(image, width: 256, height: 256);

    // Crear un tensor en el formato esperado
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

  // Combina componentes RGB en un valor compatible para setPixel de image_lib
int _combineColor(int r, int g, int b) {
  return (0xFF << 24) | (r << 16) | (g << 8) | b; // Construimos el valor ARGB manualmente
}

// Postprocesa la salida para convertirla en una imagen visualizable
Uint8List _postProcessOutput(List<dynamic> output) {
  const int width = 256;
  const int height = 256;
  final image_lib.Image restoredImage = image_lib.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final r = (output[0][y][x][0] * 255).toInt();
      final g = (output[0][y][x][1] * 255).toInt();
      final b = (output[0][y][x][2] * 255).toInt();

      // Use the Color class from image_lib
      final color = image_lib.ColorRgb8(r, g, b); 
      restoredImage.setPixel(x, y, color);
    }
  }

  return Uint8List.fromList(image_lib.encodePng(restoredImage));
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
        title: const Text('Restauración de Imágenes'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!, width: 256, height: 256)
                : const Text("Selecciona una imagen"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Seleccionar Imagen"),
            ),
            const SizedBox(height: 20),
            _restoredImageBytes != null
                ? Column(
                    children: [
                      const Text("Imagen Restaurada"),
                      Image.memory(_restoredImageBytes!, width: 256, height: 256),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
