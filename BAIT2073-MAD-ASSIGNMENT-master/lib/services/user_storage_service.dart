import 'package:firebase_auth/firebase_auth.dart';
import 'hive_storage_service.dart';
import '../model/user_model.dart';

class UserStorageService {
  // Initialize storage service
  static Future<void> init() async {
    await HiveStorageService.init();
  }

  // Save user data
  static Future<void> saveUser({
    required String uid,
    required String email,
    required String username,
    String? photoURL,
    bool emailVerified = false,
    String? provider,
  }) async {
    final userModel = UserModel(
      uid: uid,
      email: email,
      username: username,
      photoURL: photoURL,
      emailVerified: emailVerified,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      provider: provider,
    );
    await HiveStorageService.saveCurrentUser(userModel);
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = HiveStorageService.getCurrentUser();
    return user?.toMap();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return HiveStorageService.isLoggedIn();
  }

  // Update user information
  static Future<void> updateUser(Map<String, dynamic> updates) async {
    final currentUser = HiveStorageService.getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        email: updates['email'],
        username: updates['username'],
        photoURL: updates['photoURL'],
        emailVerified: updates['emailVerified'],
        phoneNumber: updates['phoneNumber'],
      );
      await HiveStorageService.updateUser(updatedUser);
    }
  }

  // Clear user data
  static Future<void> clearUserData() async {
    await HiveStorageService.clearUserData();
  }

  // Sync Firebase user to local storage
  static Future<void> syncFirebaseUser(User? firebaseUser) async {
    if (firebaseUser != null) {
      await HiveStorageService.syncFirebaseUserToHive(firebaseUser);
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return HiveStorageService.getUserId();
  }

  // Get username
  static Future<String?> getUsername() async {
    return HiveStorageService.getUsername();
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    return HiveStorageService.getUserEmail();
  }

  // Update last login time
  static Future<void> updateLastLogin() async {
    await HiveStorageService.updateLastLogin();
  }

  // Close storage service
  static Future<void> close() async {
    await HiveStorageService.close();
  }
}
