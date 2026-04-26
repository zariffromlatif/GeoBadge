import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geobadge/services/storage_service.dart';
import 'package:geobadge/models/check_in.dart';
import 'package:geobadge/features/history/history_screen.dart';
import 'package:geobadge/services/facenet_service.dart';
import 'dart:convert';
import 'package:geobadge/services/api_service.dart';
import 'package:geolocator/geolocator.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FaceNetService _faceNetService = FaceNetService();
  final MobileScannerController controller = MobileScannerController();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  bool _isProcessing = false;
  bool _faceModeActive = false;
  Color _viewfinderColor = Colors.white;

  // The Liveness Gatekeeper
  bool _isHumanLive(Face face) {
    final bool eyesOpen =
        (face.leftEyeOpenProbability ?? 0) > 0.4 &&
        (face.rightEyeOpenProbability ?? 0) > 0.4;
    final bool isFacingForward = (face.headEulerAngleY ?? 0).abs() < 10;
    return eyesOpen && isFacingForward;
  }

  // Identity Verification Logic
  // 🔍 Advanced Identity Verification Logic
  Future<void> _verifyIdentityWithStoredHash(Face face) async {
    String? storedHash = await StorageService.getEnrollmentHash();

    if (storedHash != null) {
      try {
        // 1. Convert the stored string back into a List of numbers (p)
        List<dynamic> decodedList = jsonDecode(storedHash);
        List<double> storedVector = decodedList
            .map((e) => e as double)
            .toList();

        // 2. Generate the Live Vector (q)
        // Note: For this exact moment, we are passing a mock 128-dimension vector
        // until we hook up the actual camera image stream to FaceNetService.generateVector()
        List<double> liveVector = List.filled(128, 0.0); // 🧪 Mock Live Vector

        // 3. 🧮 Calculate Euclidean Distance
        double distance = FaceNetService.calculateEuclideanDistance(
          liveVector,
          storedVector,
        );
        debugPrint("🧮 Calculated Distance: $distance");

        // 4. Threshold Check (MobileFaceNet standard is < 1.0)
        if (distance < 1.0) {
          debugPrint("Biometric Match Confirmed!");
          _onSuccess(jsonEncode(liveVector), "Actual_QR_String_From_Scanner");
        } else {
          debugPrint("❌ Match Failed. Distance too high.");
          setState(() => _isProcessing = false); // Reset so they can try again
        }
      } catch (e) {
        debugPrint("Error parsing biometric vector: $e");
        setState(() => _isProcessing = false);
      }
    } else {
      debugPrint("No enrollment found.");
      setState(() => _isProcessing = false);
    }
  }

  // The Verification Loop (Fixes the "Dead Code" warnings)
  Future<void> _startFaceVerification() async {
    if (_isProcessing) return;

    debugPrint("🤖 Analysis Pulse: Checking for human liveness...");

    // SIMULATED FACE DETECTION (For MVP testing)
    Face mockFace = Face(
      boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
      landmarks: {},
      contours: {},
      leftEyeOpenProbability: 0.8,
      rightEyeOpenProbability: 0.8,
      headEulerAngleY: 5.0,
    );

    if (_isHumanLive(mockFace)) {
      setState(() => _isProcessing = true);
      await _verifyIdentityWithStoredHash(mockFace);
    }
  }

  // Success Pulse & Haptic Logic
  void _onSuccess(String liveHash, String scannedQr) async {
    HapticFeedback.heavyImpact(); // [cite: 16, 57]

    setState(() {
      _viewfinderColor = Colors.green;
    });

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final newCheckIn = CheckIn(
      qrData: scannedQr,
      lat: position.latitude, // Real-time GPS [cite: 76]
      lng: position.longitude,
      timestamp: DateTime.now(), //
    );

    // 1. Save locally for "Offline-First" resilience [cite: 58]
    await StorageService.saveCheckIn(newCheckIn);

    // 2. Attempt Cloud Sync
    bool synced = await ApiService.syncCheckIn(newCheckIn, liveHash);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced ? "Verified & Synced!" : "Logged Locally (Offline)",
          ),
          backgroundColor: synced ? Colors.green : Colors.orange,
        ),
      );
    }

    _resetScanner(); // Reset for next person after 3s [cite: 81]
  }

  // 🟢 Fixes Error 3: Resets the state for the next user
  void _resetScanner() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _faceModeActive = false;
          _viewfinderColor = Colors.white;
        });
        // Switch back to rear camera for the next QR scan [cite: 56]
        controller.switchCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GeoBadge Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'View Check-in History',
            onPressed: () {
              // Pushes the History screen over the Scanner when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (_isProcessing || _faceModeActive) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                setState(() {
                  _faceModeActive = true;
                  _viewfinderColor =
                      Colors.blue; // Visual cue: Searching for Face
                });

                await controller.switchCamera(); // Auto-flip

                // Start the verification loop after a 1-second delay
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) _startFaceVerification();
                });
              }
            },
          ),

          // Viewfinder UI
          Center(
            //  Upgraded to AnimatedContainer for a smooth "Success Pulse"
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: _viewfinderColor, width: 4),
                borderRadius: BorderRadius.circular(_faceModeActive ? 125 : 12),
                // Adds a glowing shadow effect when successful
                boxShadow: _viewfinderColor == Colors.green
                    ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _faceDetector.close(); // Clean up the ML Kit detector
    _faceNetService.dispose(); // Clean up TFLite if method exists
    super.dispose();
  }
}
