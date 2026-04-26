import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geobadge/models/check_in.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = "https://geobadge-hub.onrender.com/v1";

  static Future<bool> syncCheckIn(CheckIn checkIn, String biometricHash) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/checkin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employee_id": "EMP-24341187", // Dynamic ID from StorageService
          "device_id": "ONEPLUS_A5000_HW_LOCKED", // [cite: 31, 73]
          "qr_payload": checkIn.qrData,
          "latitude": checkIn.lat,
          "longitude": checkIn.lng,
          "biometric_hash": biometricHash, // [cite: 33, 69]
          "timestamp": checkIn.timestamp.toIso8601String(), //
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("🚀 API Sync Successful: HTTP 200"); // [cite: 103]
        return true;
      } else {
        debugPrint("⚠️ API Sync Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Network Error: $e");
      return false;
    }
  }
}
