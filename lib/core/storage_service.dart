import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geobadge/models/check_in.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // --- 🔐 CREDENTIALS ---
  static Future<void> saveEmployeeId(String id) async =>
      await _storage.write(key: 'employee_id', value: id);

  static Future<String?> getEmployeeId() async =>
      await _storage.read(key: 'employee_id');

  // --- 📜 HISTORY LOGIC ---
  static Future<void> saveCheckIn(CheckIn checkIn) async {
    List<CheckIn> history = await getHistory();
    history.insert(0, checkIn); // Add new scan to the top

    // Limit history to last 50 scans to keep Keystore fast
    if (history.length > 50) history = history.sublist(0, 50);

    final String encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await _storage.write(key: 'checkin_history', value: encoded);
  }

  static Future<List<CheckIn>> getHistory() async {
    final String? data = await _storage.read(key: 'checkin_history');
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => CheckIn.fromJson(e)).toList();
  }
}
