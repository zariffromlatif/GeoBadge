import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geobadge/models/check_in.dart';
import 'package:flutter/foundation.dart';
import 'package:geobadge/core/constants.dart';

class ApiService {
  static final String _baseUrl = "${AppConstants.BASE_URL}/v1";

  // FIX 1: Real login validation against the backend
  static Future<Map<String, dynamic>?> login(
    String employeeId,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employee_id": employeeId,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("🔐 Login Successful");
        return jsonDecode(response.body);
      } else {
        debugPrint("⚠️ Login Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Login Network Error: $e");
      return null;
    }
  }

  // FIX 3: Employee ID is now passed dynamically instead of hardcoded
  static Future<bool> syncCheckIn(
    CheckIn checkIn,
    String biometricHash,
    String employeeId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/checkin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employee_id": employeeId,
          "device_id": "DEVICE_${DateTime.now().millisecondsSinceEpoch}",
          "qr_payload": checkIn.qrData,
          "latitude": checkIn.lat,
          "longitude": checkIn.lng,
          "biometric_hash": biometricHash,
          "timestamp": checkIn.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("🚀 API Sync Successful: HTTP 200");
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
