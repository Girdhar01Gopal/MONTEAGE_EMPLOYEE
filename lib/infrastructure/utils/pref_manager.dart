import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  // Save a value to shared preferences
  static Future<void> writeValue({required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  // Read a value from shared preferences
  static Future<String?> readValue({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Remove a value from shared preferences
  static Future<void> removeValue({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
