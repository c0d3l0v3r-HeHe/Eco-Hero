import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Create user document in Firestore if it's a new user
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await _createUserDocument(result.user!);
      }

      return result;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
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
