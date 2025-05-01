// /*
//  * FIREBASE AUTH REPOSITORY
//  * ----------------------
//  * Implementation of AuthRepository that uses Firebase Authentication.
//  *
//  * TODO: This is a placeholder for Firebase implementation.
//  * Your friend should implement this class to work with Firebase.
//  *
//  * Expected features:
//  * - Firebase Authentication integration
//  * - User data storage in Firestore
//  * - Error handling for Firebase-specific issues
//  * - Additional features like social login, password reset, etc.
//  */

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:firebase_core/firebase_core.dart';

// import '../../models/user_model.dart';
// import 'auth_repository.dart';

// class FirebaseAuthRepository implements AuthRepository {
//   FirebaseAuthRepository._();

//   @override
//   static Future<FirebaseAuthRepository> init() async {
//     await Firebase.initializeApp();
//     return FirebaseAuthRepository._();
//   }

//   @override
//   Future<User?> getCurrentUser() async {
//     // Get the current Firebase user
//     final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
//     if (firebaseUser == null) return null;

//     // Convert Firebase user to app User model
//     return User(
//       name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
//       email: firebaseUser.email!,
//       password: '', // Firebase doesn't return passwords
//     );
//   }

//   @override
//   Future<User> login(String email, String password) async {
//     // TODO: Implement login with Firebase Auth
//     // Use Firebase.auth.signInWithEmailAndPassword
//     // throw UnimplementedError('Firebase authentication not yet implemented');

//     try {
//       final userCredential =
//           await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final firebaseUser = userCredential.user!;
//       return User(
//         name: firebaseUser.displayName ?? email.split('@')[0],
//         email: email,
//         password: '', // Don't store password
//       );
//     } catch (e) {
//       throw Exception(_mapFirebaseError(e));
//     }
//   }

//   @override
//   Future<User> signUp(User user) async {
//     // TODO: Implement signUp with Firebase Auth
//     // Use Firebase.auth.createUserWithEmailAndPassword
//     // Then store additional user data in Firestore if needed
//     // throw UnimplementedError('Firebase authentication not yet implemented');
//     try {
//       final userCredential = await firebase_auth.FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: user.email,
//         password: user.password,
//       );

//       // Update display name
//       await userCredential.user!.updateDisplayName(user.name);

//       // Optional: Store additional user data in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name': user.name,
//         'email': user.email,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       return user;
//     } catch (e) {
//       throw Exception(_mapFirebaseError(e));
//     }
//   }

//   @override
//   Future<void> logout() async {
//     // TODO: Implement logout with Firebase Auth
//     // Use Firebase.auth.signOut
//     // throw UnimplementedError('Firebase authentication not yet implemented');
//     await firebase_auth.FirebaseAuth.instance.signOut();
//   }

//   String _mapFirebaseError(dynamic error) {
//     if (error is firebase_auth.FirebaseAuthException) {
//       switch (error.code) {
//         case 'user-not-found':
//           return 'No user found with this email';
//         case 'wrong-password':
//           return 'Wrong password';
//         case 'email-already-in-use':
//           return 'Email already in use';
//         // Add more cases as needed
//         default:
//           return error.message ?? 'Authentication failed';
//       }
//     }
//     return error.toString();
//   }
// }
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import 'auth_repository.dart';

/// Firebase implementation of the AuthRepository interface
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Constructor with optional dependency injection for testing
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return User(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        email: firebaseUser.email!,
      );
    }
    return null;
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }
      // Update last login time
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      // Return user data
      return User(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ??
            userCredential.user!.email!.split('@')[0],
        email: userCredential.user!.email!,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    try {
      // Create the user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      // Update the user's display name
      await userCredential.user!.updateDisplayName(name);

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Return user data
      return User(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Helper method to handle Firebase Auth exceptions
  Exception _handleAuthException(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'invalid-email':
        return Exception('Invalid email format');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Try again later');
      default:
        return Exception('Authentication error: ${error.message}');
    }
  }
}
