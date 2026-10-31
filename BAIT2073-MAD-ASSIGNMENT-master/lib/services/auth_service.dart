import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'email_service.dart';
import 'user_storage_service.dart';

class AuthService {
  // Enable Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();



  // Initialize database with URL
  DatabaseReference get database => FirebaseDatabase.instance.ref();

  // Test Realtime Database connection
  Future<bool> testDatabaseConnection() async {
    try {
      final testRef = _database.child('test');
      await testRef.set({'timestamp': ServerValue.timestamp});
      await testRef.remove();
      print('Database connection test successful');
      return true;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Registration
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Realtime Database
      if (userCredential.user != null) {
        try {
                  await _database.child('users').child(userCredential.user!.uid).set({
          'email': email,
          'username': username,
          'emailVerified': false,
          'createdAt': ServerValue.timestamp,
          'lastLogin': ServerValue.timestamp,
        });
          print('User data stored in Realtime Database');
        } catch (e) {
          print('Failed to store user data in database: $e');
        }
      }
        
      // Update display name
      await userCredential.user!.updateDisplayName(username);
        
      print('User registered successfully');
      print('User ID: ${userCredential.user!.uid}');
      print('Email: $email');
      print('Username: $username');

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // First, try to sign in with the provided password
      UserCredential? userCredential;
      
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Password reset is now handled by Firebase's built-in reset email
      } catch (e) {
        // Re-throw the original error
        throw e;
      }

      // Update last login time in Realtime Database
      if (userCredential.user != null) {
        try {
          await _database.child('users').child(userCredential.user!.uid).update({
            'lastLogin': ServerValue.timestamp,
          });
          print('Last login time updated in database');
        } catch (e) {
          print('Failed to update last login time: $e');
        }

        // Save user information to local storage
        await UserStorageService.saveUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: userCredential.user!.displayName ?? 'User',
          photoURL: userCredential.user!.photoURL,
          emailVerified: userCredential.user!.emailVerified,
          provider: 'email',
        );
      }
        
      print('User signed in successfully');
      print('User ID: ${userCredential.user!.uid}');
      print('Email: $email');

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Check if Google Play Services is available (Android only)
      print('Checking Google Play Services availability...');
      // Add Google Play Services check here if needed
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }

      print('Google user selected: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google authentication completed');
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Creating Firebase credential...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful');

      // Store user data in Realtime Database if new user
      if (userCredential.user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        try {
          await _database.child('users').child(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'username': userCredential.user!.displayName ?? 'Google User', // Use Google display name
            'photoURL': userCredential.user!.photoURL,
            'emailVerified': true, // Google accounts are pre-verified
            'emailVerifiedAt': ServerValue.timestamp,
            'createdAt': ServerValue.timestamp,
            'lastLogin': ServerValue.timestamp,
            'provider': 'google',
          });
          print('Google user data stored in Realtime Database');
        } catch (e) {
          print('Failed to store Google user data: $e');
        }
      } else if (userCredential.user != null) {
        // Update last login time for existing user
        try {
          await _database.child('users').child(userCredential.user!.uid).update({
            'lastLogin': ServerValue.timestamp,
          });
          print('Google user last login time updated');
        } catch (e) {
          print('Failed to update Google user last login time: $e');
        }
      }

      // Save user information to local storage
      if (userCredential.user != null) {
        await UserStorageService.saveUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: userCredential.user!.displayName ?? 'Google User',
          photoURL: userCredential.user!.photoURL,
          emailVerified: true, // Google accounts are pre-verified
          provider: 'google',
        );
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In error: $e');
      print('Error type: ${e.runtimeType}');
      
      // Provide more specific error messages
      String errorMessage = 'Google Sign-In failed';
      
      if (e.toString().contains('ApiException: 10')) {
        errorMessage = 'Google Play Services configuration error. Please check SHA-1 fingerprint configuration.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Sign-in was cancelled.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Google Sign-In failed. Please try again or use email/password login.';
      }
      
      throw errorMessage;
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Custom Password Reset with our own email template
  Future<void> resetPasswordWithCustomEmail(String email) async {
    try {
      // First, send Firebase's reset email to get the reset link
      await _auth.sendPasswordResetEmail(email: email);
      
      // Get user data for username
      final userData = await _findUserByEmail(email);
      final username = userData?['username'] ?? 'User';
      
      // Note: We can't get the actual reset link from Firebase's sendPasswordResetEmail
      // So we'll use a fallback approach - send our own email with instructions
      if (EmailService.isConfigured()) {
        // Create a custom reset link (this would need to be handled differently in production)
        final customResetLink = 'https://madassignment-c2881.firebaseapp.com/reset-password?email=$email';
        
        final emailSent = await EmailService.sendPasswordResetEmail(
          recipientEmail: email,
          resetLink: customResetLink,
          username: username,
        );
        
        if (emailSent) {
          print('Custom password reset email sent successfully to: $email');
        } else {
          print('Failed to send custom password reset email, using Firebase default');
        }
      } else {
        print('Email service not configured, using Firebase default reset email');
      }
    } catch (e) {
      print('Error in custom password reset: $e');
      throw _handleAuthException(e);
    }
  }

  // Reset Password with Email (for forgot password flow) - Removed as we now use Firebase's built-in reset

  // Find user by email in Realtime Database
  Future<Map<String, dynamic>?> _findUserByEmail(String email) async {
    try {
      final snapshot = await _database.child('users').get();
      if (snapshot.exists) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);
        
        for (String uid in users.keys) {
          final userData = Map<String, dynamic>.from(users[uid] as Map);
          if (userData['email'] == email) {
            userData['uid'] = uid; // Add UID to the user data
            return userData;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      print('Password updated successfully');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear locally stored user data
      await UserStorageService.clearUserData();
      
      print('User signed out successfully');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DataSnapshot snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _database.child('users').child(uid).update(data);
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw 'Failed to update user profile: $e';
    }
  }



  // Handle Firebase Auth Exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'Authentication error: $e';
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Check email service configuration status
  String getEmailServiceStatus() {
    return EmailService.getConfigurationStatus();
  }

  // Test email service configuration
  Future<bool> testEmailService() async {
    try {
      if (!EmailService.isConfigured()) {
        return false;
      }
      
      // Try to send a test email for registration verification
      final testResult = await EmailService.sendOTPEmail(
        recipientEmail: 'test@example.com',
        otp: '123456',
        username: 'Test User',
      );
      
      return testResult;
    } catch (e) {
      print('Email service test failed: $e');
      return false;
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      print('Email verification resent successfully');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reload user to check verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      print('User reloaded successfully');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }



  // Update user verification status in database
  Future<void> updateEmailVerificationStatus(String uid, bool verified) async {
    try {
      await _database.child('users').child(uid).update({
        'emailVerified': verified,
        'emailVerifiedAt': verified ? ServerValue.timestamp : null,
      });
      print('Email verification status updated in database');
    } catch (e) {
      print('Failed to update email verification status: $e');
    }
  }

  // OTP methods for registration verification (not password reset)
  String _generateOTP() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  // Store OTP in database (for verification)
  Future<void> _storeOTP(String email, String otp) async {
    try {
      final emailKey = email.replaceAll('.', '_');
      final expiresAt = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;
      
      await _database.child('otp').child(emailKey).set({
        'otp': otp,
        'timestamp': ServerValue.timestamp,
        'expiresAt': expiresAt,
      });
      print('OTP stored in database');
    } catch (e) {
      print('Failed to store OTP: $e');
    }
  }

  // Send OTP email for registration verification
  Future<String> sendOTPEmail(String email, {String? username}) async {
    try {
      final otp = _generateOTP();
      await _storeOTP(email, otp);
      
      // Check if email service is configured
      if (!EmailService.isConfigured()) {
        print('Email service not configured. Using fallback mode.');
        print('OTP Code for testing: $otp');
        return otp;
      }
      
      // Send real email using EmailService
      final emailSent = await EmailService.sendOTPEmail(
        recipientEmail: email,
        otp: otp,
        username: username ?? 'User',
      );
      
      if (emailSent) {
        print('OTP email sent successfully to: $email');
        return otp;
      } else {
        print('Failed to send OTP email, using fallback mode');
        print('OTP Code for testing: $otp');
        return otp;
      }
    } catch (e) {
      print('Error sending OTP email: $e');
      // Fallback to showing OTP in console for testing
      final otp = _generateOTP();
      await _storeOTP(email, otp);
      print('Fallback OTP Code: $otp');
      return otp;
    }
  }

  // Verify OTP for registration
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final emailKey = email.replaceAll('.', '_');
      
      final snapshot = await _database.child('otp').child(emailKey).get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final storedOTP = data['otp'] as String;
        final expiresAt = data['expiresAt'] as int;
        
        // Check if OTP is expired
        if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
          print('OTP has expired');
          return false;
        }
        
        // Verify OTP
        if (storedOTP == otp) {
          // Remove OTP after successful verification
          await _database.child('otp').child(emailKey).remove();
          print('OTP verified successfully');
          return true;
        } else {
          print('Invalid OTP code');
          return false;
        }
      } else {
        print('No OTP found for this email');
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
