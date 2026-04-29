import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geobadge/models/check_in.dart';
import 'dart:math';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _enrolledKey = 'is_enrolled';
  static const String _historyKey = 'checkin_history';
  static const String _faceHashKey = 'enrollment_hash';
  static const String _employeeIdKey = 'employee_id';

  // Fixes the scanner_screen.dart error
  static Future<void> saveCheckIn(CheckIn checkIn) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_historyKey) ?? [];
    history.add(jsonEncode(checkIn.toJson()));
    await prefs.setStringList(_historyKey, history);
  }

  // Fixes the history_screen.dart error
  static Future<List<CheckIn>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_historyKey) ?? [];
    return history.map((item) => CheckIn.fromJson(jsonDecode(item))).toList();
  }

  // Saves your 512-character biometric vector baseline
  static Future<void> saveEnrollmentHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_faceHashKey, hash);
  }

  // Retrieves the hash for comparison during daily check-ins
  static Future<String?> getEnrollmentHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_faceHashKey);
  }

  // Save the login token provided by HR
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Check if a user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // Mark face enrollment as complete
  static Future<void> setEnrolled(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enrolledKey, status);
  }

  // Check if the user needs to do their first-time face scan
  static Future<bool> isEnrolled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enrolledKey) ?? false;
  }

  // FIX 3: Save the authenticated employee's ID
  static Future<void> saveEmployeeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeIdKey, id);
  }

  // FIX 3: Retrieve the authenticated employee's ID
  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class BiometricService {
  //The "Heart" of the verification engine
  static double calculateDistance(
    List<double> liveVector,
    List<double> storedVector,
  ) {
    double sum = 0;
    for (int i = 0; i < liveVector.length; i++) {
      sum += pow(liveVector[i] - storedVector[i], 2);
    }
    return sqrt(sum);
  }

  // Helper to convert your stored string back into a List of doubles
  static List<double> parseVector(String vectorString) {
    // In production, this would parse your 512-character string
    // For now, we strip your "VEC_" prefix and convert to dummy data
    return vectorString.split('_').last.runes.map((r) => r.toDouble()).toList();
  }
}
