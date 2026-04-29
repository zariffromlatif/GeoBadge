import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geobadge/core/constants.dart';

class ApiService {
  static final String _baseUrl = "${AppConstants.baseUrl}/v1";
  static const _storage = FlutterSecureStorage();

  /// --- 🔐 PHASE 1: ONE-TIME ONBOARDING ---
  static Future<bool> login(String employeeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"employee_id": employeeId, "password": password}),
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'employee_id', value: employeeId);
        debugPrint("🔐 Credentials Secured in Keystore");
        return true;
      } else {
        debugPrint("⚠️ Onboarding Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Onboarding Network Error: $e");
      return false;
    }
  }

  /// --- 🛰️ PHASE 2: INVISIBLE CHECK-IN ---
  /// Now includes Location Service and Permission handling.
  static Future<Map<String, dynamic>> performCheckIn(String siteId) async {
    try {
      // 1. Verify Location Services are actually ON
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {"success": false, "message": "GPS IS TURNED OFF"};
      }

      // 2. Proactive Permission Handshake
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {"success": false, "message": "LOCATION PERMISSION DENIED"};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {"success": false, "message": "ENABLE GPS IN SETTINGS"};
      }

      // 3. Silently pull ID from Secure Storage
      final String? empId = await _storage.read(key: 'employee_id');

      // 4. Silently fetch precise GPS
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // 5. Package the Geo-Validated Payload
      final Map<String, dynamic> payload = {
        "employee_id": empId ?? "UNREGISTERED",
        "device_id": "OP5_HANDHELD",
        "site_id": siteId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      };

      // 6. Automated POST Transmission
      final response = await http.post(
        Uri.parse("$_baseUrl/checkin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint(
          "🚀 Success: Check-in Verified at ${decodedResponse['distance_m']}m",
        );
        return {"success": true, "message": decodedResponse['message']};
      } else {
        // This captures the 'Outside Geofence' message from Render
        debugPrint("⚠️ Denied: ${decodedResponse['detail']}");
        return {
          "success": false,
          "message": decodedResponse['detail'].toString().toUpperCase(),
        };
      }
    } catch (e) {
      debugPrint("❌ Transmission Error Detail: $e");

      // Determine if it's a timeout, a network fail, or a logic error
      String errorMsg = "CONNECTION ERROR";
      if (e.toString().contains("TimeoutException"))
        errorMsg = "GPS TIMEOUT: TRY AGAIN";
      if (e.toString().contains("permission")) errorMsg = "PERMISSION ERROR";

      return {"success": false, "message": errorMsg};
    }
  }

  /// --- 🛠️ HELPER: CHECK SETUP STATUS ---
  static Future<bool> isUserSetup() async {
    String? id = await _storage.read(key: 'employee_id');
    return id != null;
  }
}
