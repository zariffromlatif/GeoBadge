import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class FaceNetService {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  void dispose() {
    {
      _interpreter.close();
    }
  }

  // 1. Initialize the TensorFlow Lite Model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      _isModelLoaded = true;
      debugPrint("MobileFaceNet Model Loaded Successfully");
    } catch (e) {
      debugPrint("Failed to load TFLite model: $e");
    }
  }

  Future<img.Image> cropFace(InputImage inputImage, Face face) async {
    // 1. Extract the raw bytes from the camera frame
    final bytes = inputImage.bytes;

    // 2. Decode the full image
    img.Image? fullImage = img.decodeImage(bytes!);

    // 3. Get the bounding box from the ML Kit face detection
    final rect = face.boundingBox;

    // 4. Crop the image to just the face area
    img.Image croppedFace = img.copyCrop(
      fullImage!,
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );

    // 5. Resize to 112x112 (The exact input size MobileFaceNet requires)
    return img.copyResize(croppedFace, width: 112, height: 112);
  }

  // 2. The Core Generation Engine
  List<double>? generateVector(img.Image faceImage) {
    if (!_isModelLoaded) return null;

    // MobileFaceNet strictly requires a 112x112 pixel input
    img.Image resizedImage = img.copyResize(faceImage, width: 112, height: 112);

    // Preprocess: Convert image pixels to a normalized 4D Tensor array
    // Shape required by MobileFaceNet: [1, 112, 112, 3]
    var input = _imageToTensor(resizedImage);

    // Output shape: [1, 128] (This is your 128-dimension biometric hash)
    var output = List.generate(1, (index) => List.filled(128, 0.0));

    // 🚀 Run local edge inference
    _interpreter.run(input, output);

    // Return the 128-character mathematical string
    return output[0];
  }

  // 3. Pixel Normalization (Mathematical Preprocessing)
  List<List<List<List<double>>>> _imageToTensor(img.Image image) {
    var input = List.generate(
      1,
      (i) => List.generate(
        112,
        (y) => List.generate(112, (x) => List.generate(3, (c) => 0.0)),
      ),
    );

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        img.Pixel pixel = image.getPixel(x, y);

        // Normalize RGB values from [0, 255] to [-1.0, 1.0] for the neural network
        input[0][y][x][0] = (pixel.r - 127.5) / 128.0;
        input[0][y][x][1] = (pixel.g - 127.5) / 128.0;
        input[0][y][x][2] = (pixel.b - 127.5) / 128.0;
      }
    }
    return input;
  }

  static double calculateEuclideanDistance(
    List<double> vector1,
    List<double> vector2,
  ) {
    double sum = 0.0;
    for (int i = 0; i < vector1.length; i++) {
      sum += pow((vector1[i] - vector2[i]), 2);
    }
    return sqrt(sum);
  }
}
