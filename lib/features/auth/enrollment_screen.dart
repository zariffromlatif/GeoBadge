import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geobadge/services/storage_service.dart';
import 'package:geobadge/features/auth/auth_wrapper.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.front, // Always front for enrollment
  );

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true, // Needed for our "Biometric Vector"
    ),
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _captureEnrollment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // This represents the 512-character vector discussed for your thesis
    String mockVector = "VEC_${DateTime.now().millisecondsSinceEpoch}_24341187";

    // Use the variable to save the baseline hash
    await StorageService.saveEnrollmentHash(mockVector);

    // Mark user as enrolled so the gatekeeper lets them through
    await StorageService.setEnrolled(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Face Enrollment Successful!")),
      );
      //ADD THIS: Tell the app to refresh and send you to the Scanner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Enrollment")),
      body: Stack(
        children: [
          MobileScanner(controller: controller),

          // The Circular Viewfinder
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 4),
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  "Center your face in the circle\nand tap the button below",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _captureEnrollment,
                  icon: const Icon(Icons.face),
                  label: const Text("REGISTER MY FACE"),
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
