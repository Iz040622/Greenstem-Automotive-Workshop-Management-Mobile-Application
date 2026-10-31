import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class HiveStorageService {
  static const String _userBoxName = 'user_box';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  static Box<dynamic>? _userBox;

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    
    // Open user data box
    _userBox = await Hive.openBox(_userBoxName);
  }

  // Save current user
  static Future<void> saveCurrentUser(UserModel user) async {
    try {
      await _userBox?.put(_currentUserKey, user);
      await _userBox?.put(_isLoggedInKey, true);
      print('User data saved to Hive');
    } catch (e) {
      print('Failed to save user data: $e');
    }
  }

  // Get current user
  static UserModel? getCurrentUser() {
    try {
      return _userBox?.get(_currentUserKey) as UserModel?;
    } catch (e) {
      print('Failed to get user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    try {
      final result = _userBox?.get(_isLoggedInKey, defaultValue: false);
      return result is bool ? result : false;
    } catch (e) {
      print('Failed to check login status: $e');
      return false;
    }
  }

  // Update user information
  static Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _userBox?.put(_currentUserKey, updatedUser);
      print('User data updated');
    } catch (e) {
      print('Failed to update user data: $e');
    }
  }

  // Clear user data
  static Future<void> clearUserData() async {
    try {
      await _userBox?.delete(_currentUserKey);
      await _userBox?.put(_isLoggedInKey, false);
      print('User data cleared');
    } catch (e) {
      print('Failed to clear user data: $e');
    }
  }

  // Sync Firebase user to Hive
  static Future<void> syncFirebaseUserToHive(User? firebaseUser) async {
    if (firebaseUser != null) {
      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      await saveCurrentUser(userModel);
    }
  }

  // Get user ID
  static String? getUserId() {
    final user = getCurrentUser();
    return user?.uid;
  }

  // Get username
  static String? getUsername() {
    final user = getCurrentUser();
    return user?.username;
  }

  // Get user email
  static String? getUserEmail() {
    final user = getCurrentUser();
    return user?.email;
  }

  // Update last login time
  static Future<void> updateLastLogin() async {
    final currentUser = getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(lastLogin: DateTime.now());
      await updateUser(updatedUser);
    }
  }

  // Close Hive
  static Future<void> close() async {
    await _userBox?.close();
  }
}
