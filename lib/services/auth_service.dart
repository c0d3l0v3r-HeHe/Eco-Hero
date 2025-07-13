import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result;

      // Use a more defensive approach to handle potential type casting issues
      try {
        result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          // Handle the specific Pigeon type casting error
          print('Handling Pigeon type casting error during sign in');
          // Wait a moment and try again
          await Future.delayed(const Duration(milliseconds: 500));
          result = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      return result;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result;

      // Use a more defensive approach to handle potential type casting issues
      try {
        result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          // Handle the specific Pigeon type casting error
          print('Handling Pigeon type casting error during registration');
          // Wait a moment and try again
          await Future.delayed(const Duration(milliseconds: 500));
          result = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      // Update display name
      await result.user?.updateDisplayName(name);

      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!);
      }

      return result;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');

      // Check if Google Sign-In is available
      if (!await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // Ensure clean state
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google user: $googleUser');

      if (googleUser == null) {
        print('User canceled the sign-in');
        return null;
      }

      print('Getting Google authentication details...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(
        'Access token: ${googleAuth.accessToken != null ? "Present" : "Missing"}',
      );
      print('ID token: ${googleAuth.idToken != null ? "Present" : "Missing"}');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception(
          'Failed to get authentication tokens from Google. Please check your Google Sign-In configuration.',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      print('Firebase sign-in successful: ${result.user?.email}');

      // Create user document in Firestore if it's a new user
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        print('Creating user document for new user...');
        await _createUserDocument(result.user!);
      }

      return result;
    } catch (e, stackTrace) {
      print('Error signing in with Google: $e');
      print('Stack trace: $stackTrace');

      // Handle specific Google Sign-In errors with better messages
      String errorMessage = 'Google Sign-In failed. ';

      if (e.toString().toLowerCase().contains('sign_in_failed') ||
          e.toString().contains('10:') ||
          e.toString().toLowerCase().contains('developer_error')) {
        errorMessage +=
            'Google Sign-In is not properly configured for this app. Please use email/password login instead.';
      } else if (e.toString().toLowerCase().contains('network_error') ||
          e.toString().toLowerCase().contains('network')) {
        errorMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().toLowerCase().contains('canceled') ||
          e.toString().toLowerCase().contains('cancelled')) {
        errorMessage += 'Sign-in was cancelled.';
      } else if (e.toString().toLowerCase().contains('timeout')) {
        errorMessage += 'Sign-in timed out. Please try again.';
      } else {
        errorMessage += 'Please try again or use email/password login.';
      }

      throw Exception(errorMessage);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'Eco Hero',
        'photoURL': user.photoURL,
        'ecoPoints': 0,
        'level': 1,
        'joinedAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'tasksCompleted': 0,
        'carbonFootprint': 0.0,
        'achievements': [],
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Update user eco points
  Future<void> updateEcoPoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'ecoPoints': FieldValue.increment(points),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating eco points: $e');
      rethrow;
    }
  }

  // Update user level
  Future<void> updateUserLevel(String uid, int level) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'level': level,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user level: $e');
      rethrow;
    }
  }

  // Get authentication error message
  String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
