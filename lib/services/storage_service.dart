import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastResultKey = 'last_result';

  // Save the last result (score and message) to shared_preferences
  Future<void> saveLastResult(String result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResultKey, result);
  }

  // Retrieve the last result from shared_preferences
  Future<String?> getLastResult() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastResultKey);
  }

  // Clear the last result (optional, in case you need to reset it)
  Future<void> clearLastResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastResultKey);
  }
}