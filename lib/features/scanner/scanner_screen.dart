import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:geobadge/services/api_service.dart';
import 'package:geobadge/features/history/history_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // 🟢 Optimized Controller: No returnImage needed = Higher FPS
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  Color _viewfinderColor = Colors.white;
  String _statusText = "ALIGN QR CODE";

  /// The Core Pipeline: Scan -> Secure Payload -> Transmission
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String qrData = barcodes.first.rawValue ?? "";
    if (qrData.isEmpty) return;

    // 1. Initial Feedback (Scanner acknowledged the QR)
    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _viewfinderColor = Colors.blue;
      _statusText = "VERIFYING...";
    });

    // 2. Perform the Geofenced Check-in (GPS + API)
    // api_service handles the Keystore and Geolocator internally
    final result = await ApiService.performCheckIn(qrData);

    if (result['success']) {
      _triggerSuccess(result['message']);
    } else {
      _triggerFailure(result['message']);
    }
  }

  void _triggerSuccess(String message) {
    // Satisfying long haptic pulse
    Vibration.vibrate(duration: 500);

    setState(() {
      _viewfinderColor = Colors.green;
      _statusText = message.toUpperCase();
    });
    _resetScanner();
  }

  void _triggerFailure(String message) {
    // Distinct "Double-Buzz" for errors
    Vibration.vibrate(pattern: [0, 200, 100, 200]);

    setState(() {
      _viewfinderColor = Colors.red;
      _statusText = message.toUpperCase();
    });
    _resetScanner();
  }

  void _resetScanner() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _viewfinderColor = Colors.white;
          _statusText = "ALIGN QR CODE";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Industrial OLED look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "GEOBADGE SCANNER",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_on, color: Colors.white70),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Full Screen Scanner
          MobileScanner(controller: controller, onDetect: _onDetect),

          // 2. Minimalist UI Overlay
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: _viewfinderColor, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_viewfinderColor != Colors.white)
                    BoxShadow(
                      color: _viewfinderColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Corner accents for the industrial look
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),

                  Center(
                    child: Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _viewfinderColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Status Bar at Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "GEO-VALIDATION ACTIVE",
                style: TextStyle(
                  color: Colors.white..withValues(alpha: 0.3),
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment align) {
    return Align(
      alignment: align,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _viewfinderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
