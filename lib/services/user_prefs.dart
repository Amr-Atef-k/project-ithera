import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _userIdKey = 'user_id';
  static const _rememberMeKey = 'remember_me';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Save "Remember Me" state, email, and password
  static Future<void> saveRememberMe({
    required bool rememberMe,
    String? email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe && email != null && password != null) {
      await prefs.setString(_emailKey, email);
      await prefs.setString(_passwordKey, password);
    } else {
      // Clear credentials if "Remember Me" is unchecked
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
    }
  }

  // Get "Remember Me" state
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Get saved email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get saved password
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // Clear all "Remember Me" data
  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}