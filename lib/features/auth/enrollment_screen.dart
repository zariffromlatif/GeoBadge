import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geobadge/services/storage_service.dart';
import 'package:geobadge/services/facenet_service.dart';
import 'package:geobadge/features/auth/auth_wrapper.dart';
import 'dart:convert';
import 'dart:typed_data';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.front,
    returnImage: true, // FIX 2: Enable image capture for FaceNet processing
  );

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
    ),
  );

  final FaceNetService _faceNetService = FaceNetService();
  bool _isProcessing = false;
  bool _faceDetected = false;

  // Store the latest captured data for processing
  Uint8List? _latestImage;
  Size _latestSize = Size.zero;
  Face? _latestFace;

  @override
  void initState() {
    super.initState();
    _faceNetService.loadModel();
  }

  @override
  void dispose() {
    controller.dispose();
    _faceDetector.close();
    _faceNetService.dispose();
    super.dispose();
  }

  // FIX 2: Real enrollment using FaceNet — saves actual 128-dim vector as JSON
  Future<void> _captureEnrollment() async {
    if (_isProcessing) return;

    if (_latestImage == null || _latestFace == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No face detected. Position your face in the circle.")),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromBytes(
        bytes: _latestImage!,
        metadata: InputImageMetadata(
          size: _latestSize,
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21,
          bytesPerRow: _latestSize.width.toInt(),
        ),
      );

      // Crop face and run MobileFaceNet to generate the real 128-dim vector
      final faceImage = await _faceNetService.cropFace(inputImage, _latestFace!);
      final List<double>? vector = _faceNetService.generateVector(faceImage);

      if (vector == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not generate face vector. Try again.")),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // FIX 2: Save the REAL vector as JSON array (not a fake "VEC_" string)
      // This matches what scanner_screen.dart expects via jsonDecode()
      await StorageService.saveEnrollmentHash(jsonEncode(vector));
      await StorageService.setEnrolled(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Face Enrollment Successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    } catch (e) {
      debugPrint("Enrollment Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enrollment failed: $e")),
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Enrollment")),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              // Continuously capture frames and detect faces
              final image = capture.image;
              final size = capture.size;

              if (image != null && size != Size.zero && !_isProcessing) {
                final inputImage = InputImage.fromBytes(
                  bytes: image,
                  metadata: InputImageMetadata(
                    size: size,
                    rotation: InputImageRotation.rotation270deg,
                    format: InputImageFormat.nv21,
                    bytesPerRow: size.width.toInt(),
                  ),
                );

                final faces = await _faceDetector.processImage(inputImage);

                if (faces.isNotEmpty) {
                  setState(() {
                    _faceDetected = true;
                    _latestImage = image;
                    _latestSize = size;
                    _latestFace = faces.first;
                  });
                } else {
                  if (mounted) setState(() => _faceDetected = false);
                }
              }
            },
          ),

          // The Circular Viewfinder — turns green when face is detected
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _faceDetected ? Colors.green : Colors.blueAccent,
                  width: 4,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _faceDetected
                      ? "Face detected! Tap to register."
                      : "Center your face in the circle",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _captureEnrollment,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.face),
                  label: Text(
                    _isProcessing ? "PROCESSING..." : "REGISTER MY FACE",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
