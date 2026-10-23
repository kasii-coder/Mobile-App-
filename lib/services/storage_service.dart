import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _keyLoggedIn = 'gamevault_is_logged_in';
  static const String _keyLightMode = 'gamevault_is_light_mode';
  static const String _keyUserProfile = 'gamevault_user_profile';
  static const String _keyLastLoggedAccount = 'gamevault_last_logged_account';
  static const String _keyProfileImage = 'gamevault_profile_image';

  static SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance.
  static Future<SharedPreferences> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Sets custom SharedPreferences instance (useful for unit testing).
  static void setMockInstance(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// Returns true if the user is currently logged in.
  /// If true, the app will never show the login screen until the user logs out.
  static bool isLoggedIn() {
    return _prefs?.getBool(_keyLoggedIn) ?? false;
  }

  /// Persists the user's login state.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await init();
    await prefs.setBool(_keyLoggedIn, value);
  }

  /// Returns the saved theme mode preference.
  static bool isLightMode({bool defaultValue = false}) {
    return _prefs?.getBool(_keyLightMode) ?? defaultValue;
  }

  /// Persists the user's light/dark mode preference.
  static Future<void> setLightMode(bool value) async {
    final prefs = await init();
    await prefs.setBool(_keyLightMode, value);
  }

  /// Loads the persisted UserProfile or returns [defaultProfile] if not saved.
  static UserProfile loadUserProfile(UserProfile defaultProfile) {
    final raw = _prefs?.getString(_keyUserProfile) ??
        _prefs?.getString(_keyLastLoggedAccount);
    if (raw == null || raw.isEmpty) return defaultProfile;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(map);
      // Check if there is also a separately stored profile image
      final savedImage = _prefs?.getString(_keyProfileImage);
      if (savedImage != null && savedImage.isNotEmpty && profile.imagePath == null) {
        return profile.copyWith(imagePath: savedImage);
      }
      return profile;
    } catch (_) {
      return defaultProfile;
    }
  }

  /// Returns the last logged in UserProfile if available.
  static UserProfile? getLastLoggedAccount() {
    final raw = _prefs?.getString(_keyLastLoggedAccount) ??
        _prefs?.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(map);
      final savedImage = _prefs?.getString(_keyProfileImage);
      if (savedImage != null && savedImage.isNotEmpty && profile.imagePath == null) {
        return profile.copyWith(imagePath: savedImage);
      }
      return profile;
    } catch (_) {
      return null;
    }
  }

  /// Persists the user's profile to SharedPreferences.
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await init();
    final raw = jsonEncode(profile.toJson());
    await prefs.setString(_keyUserProfile, raw);
    await prefs.setString(_keyLastLoggedAccount, raw);

    if (profile.imagePath != null && profile.imagePath!.isNotEmpty) {
      await prefs.setString(_keyProfileImage, profile.imagePath!);
    } else {
      await prefs.remove(_keyProfileImage);
    }
  }

  /// Persists selected profile image string (path or base64) to SharedPreferences.
  static Future<void> saveProfileImage(String? image) async {
    final prefs = await init();
    if (image != null && image.isNotEmpty) {
      await prefs.setString(_keyProfileImage, image);
    } else {
      await prefs.remove(_keyProfileImage);
    }
  }

  /// Returns saved profile image string.
  static String? getSavedProfileImage() {
    return _prefs?.getString(_keyProfileImage);
  }

  /// Clears stored login session while preserving saved profile & account details for quick login.
  static Future<void> logout() async {
    final prefs = await init();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
