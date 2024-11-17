import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;

class ArtworkDelimiter {
  late Interpreter _interpreter;
  bool isDownloading = false;
  bool isProcessing = false;

  ArtworkDelimiter._internal();

  static final ArtworkDelimiter _instance = ArtworkDelimiter._internal();

  factory ArtworkDelimiter() => _instance;

  Future<void> initialize(String modelName) async {
    isDownloading = true;
    try {
      final model = await FirebaseModelDownloader.instance.getModel(
        modelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );
      _interpreter = Interpreter.fromFile(model.file);
      print("Artwork Delimiter Model loaded successfully");
    } catch (e) {
      throw Exception("Error loading Artwork Delimiter model: $e");
    } finally {
      isDownloading = false;
    }
  }

/*
  Future<Uint8List> cropArtwork(Uint8List inputImage) async {
    isProcessing = true;
    try {
      final rawOutput = _runInference(inputImage);
      print("Raw model output: $rawOutput");

      final boxes = _filterBoundingBoxes(rawOutput[0]);
      if (boxes.isEmpty) {
        print("No bounding boxes detected");
        return inputImage; // Return original image if no boxes detected
      }

      // Use the box with the highest confidence
      final bestBox = boxes.first;
      print("Best bounding box: $bestBox");

      return _applyCropping(inputImage, bestBox);
    } catch (e) {
      throw Exception("Error during cropping: $e");
    } finally {
      isProcessing = false;
    }
  }
*/

Future<Uint8List> cropArtwork(Uint8List imageBytes) async {
  // Decode the image
  final image_lib.Image? image = image_lib.decodeImage(imageBytes);
  if (image == null) throw Exception("Failed to decode image");

  // Example bounding box from ML output
  final List<double> boundingBox = [0.1, 0.1, 0.8, 0.8]; // Dummy values

  // Calculate crop coordinates
  final x = (boundingBox[0] * image.width).toInt();
  final y = (boundingBox[1] * image.height).toInt();
  final width = ((boundingBox[2] - boundingBox[0]) * image.width).toInt();
  final height = ((boundingBox[3] - boundingBox[1]) * image.height).toInt();

  // Validate crop dimensions
  if (x < 0 || y < 0 || width <= 0 || height <= 0 || x + width > image.width || y + height > image.height) {
    throw Exception("Invalid bounding box for cropping");
  }

  // Perform cropping
  final croppedImage = image_lib.copyCrop(image,x: x, y: y, width: width, height: height);

  return Uint8List.fromList(image_lib.encodePng(croppedImage));
}

  List<dynamic> _runInference(Uint8List inputImage) {
    final input = _preprocessImage(inputImage);
    final output = List.generate(1 * 25200 * 6, (index) => 0.0).reshape([1, 25200, 6]);

    try {
      _interpreter.run(input, output);
      return output;
    } catch (e) {
      throw Exception("Error during inference: $e");
    }
  }

  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");

    image_lib.Image resizedImage = image_lib.copyResize(image, width: 640, height: 640);

    List<List<List<List<double>>>> input = [
      List.generate(
        640,
        (y) => List.generate(
          640,
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


  List<dynamic> _filterBoundingBoxes(List<List<double>> output) {
    const double threshold = 0.3; // Lowered threshold
    final filteredBoxes = <dynamic>[];

    for (final box in output) {
      final confidence = box[4];
      if (confidence > threshold) {
        filteredBoxes.add(box);
      }
    }

    filteredBoxes.sort((a, b) => b[4].compareTo(a[4])); // Sort by confidence
    return filteredBoxes;
  }

  Uint8List _applyCropping(Uint8List inputImage, dynamic box) {
    final xMin = box[0];
    final yMin = box[1];
    final xMax = box[2];
    final yMax = box[3];

    final originalImage = image_lib.decodeImage(inputImage);
    if (originalImage == null) throw Exception("Failed to decode image");

    final cropped = image_lib.copyCrop(
      originalImage,
      x: (xMin * originalImage.width).toInt(),
      y: (yMin * originalImage.height).toInt(),
      width: ((xMax - xMin) * originalImage.width).toInt(),
      height: ((yMax - yMin) * originalImage.height).toInt(),
    );

    return Uint8List.fromList(image_lib.encodePng(cropped));
  }
}
