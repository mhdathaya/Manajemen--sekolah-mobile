import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';

/// Service untuk manage local storage menggunakan SharedPreferences
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._internal();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Token Authentication
  Future<void> saveToken(String token) async {
    await _preferences?.setString(AppConstants.keyToken, token);
  }

  String? getToken() {
    return _preferences?.getString(AppConstants.keyToken);
  }

  Future<void> removeToken() async {
    await _preferences?.remove(AppConstants.keyToken);
  }

  // User Role
  Future<void> saveUserRole(String role) async {
    await _preferences?.setString(AppConstants.keyUserRole, role);
  }

  String? getUserRole() {
    return _preferences?.getString(AppConstants.keyUserRole);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _preferences?.setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() {
    return _preferences?.getString(AppConstants.keyUserId);
  }

  // User Name
  Future<void> saveUserName(String name) async {
    await _preferences?.setString(AppConstants.keyUserName, name);
  }

  String? getUserName() {
    return _preferences?.getString(AppConstants.keyUserName);
  }

  // User Email
  Future<void> saveUserEmail(String email) async {
    await _preferences?.setString(AppConstants.keyUserEmail, email);
  }

  String? getUserEmail() {
    return _preferences?.getString(AppConstants.keyUserEmail);
  }

  // Login Status
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _preferences?.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return _preferences?.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // User Data (sebagai JSON string)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonStr = jsonEncode(userData);
    await _preferences?.setString(AppConstants.keyUserData, jsonStr);
  }

  Map<String, dynamic>? getUserData() {
    final jsonStr = _preferences?.getString(AppConstants.keyUserData);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // Clear All Data (Logout)
  Future<void> clearAll() async {
    await _preferences?.clear();
  }

  // Clear specific keys
  Future<void> removeKey(String key) async {
    await _preferences?.remove(key);
  }

  // Generic save/get methods
  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }
}
