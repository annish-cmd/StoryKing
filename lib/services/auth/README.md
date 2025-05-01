# Authentication System Guide

## Overview

This folder contains a modular authentication system designed for easy switching between local authentication (currently used) and Firebase authentication (to be implemented).

## Files Structure

- `auth_repository.dart` - Interface that defines the contract for auth implementations
- `local_auth_repository.dart` - Implementation using SharedPreferences (currently active)
- `firebase_auth_repository.dart` - Placeholder for Firebase implementation (TODO)
- `auth_service.dart` - Service provider that selects the appropriate implementation

## How to Implement Firebase Authentication

### 1. Setup Firebase

1. Add Firebase dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^latest_version
     firebase_auth: ^latest_version
     cloud_firestore: ^latest_version  # If storing additional user data
   ```

2. Run `flutter pub get` to install dependencies

3. Configure Firebase for your app following the Firebase Flutter documentation:
   - Android: Add `google-services.json` 
   - iOS: Add `GoogleService-Info.plist`

4. Initialize Firebase in `main.dart` before calling `runApp()`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     // Continue with existing code...
     final authService = await AuthService.init();
     // ...
   }
   ```

### 2. Implement FirebaseAuthRepository

Open `firebase_auth_repository.dart` and implement the methods:

1. **Initialize Firebase Auth**:
   ```dart
   static Future<FirebaseAuthRepository> init() async {
     // Firebase.initializeApp() should already be called in main()
     return FirebaseAuthRepository._();
   }
   ```

2. **Get Current User**:
   ```dart
   Future<User?> getCurrentUser() async {
     final firebaseUser = FirebaseAuth.instance.currentUser;
     if (firebaseUser == null) return null;
     
     // Convert Firebase user to app User model
     return User(
       name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
       email: firebaseUser.email!,
       password: '', // Firebase doesn't return passwords
     );
   }
   ```

3. **Login**:
   ```dart
   Future<User> login(String email, String password) async {
     try {
       final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email,
         password: password,
       );
       
       final firebaseUser = userCredential.user!;
       return User(
         name: firebaseUser.displayName ?? email.split('@')[0],
         email: email,
         password: '', // Don't store password
       );
     } catch (e) {
       throw Exception(_mapFirebaseError(e));
     }
   }
   ```

4. **Sign Up**:
   ```dart
   Future<User> signUp(User user) async {
     try {
       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: user.email,
         password: user.password,
       );
       
       // Update display name
       await userCredential.user!.updateDisplayName(user.name);
       
       // Optional: Store additional user data in Firestore
       await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
         'name': user.name,
         'email': user.email,
         'createdAt': FieldValue.serverTimestamp(),
       });
       
       return user;
     } catch (e) {
       throw Exception(_mapFirebaseError(e));
     }
   }
   ```

5. **Logout**:
   ```dart
   Future<void> logout() async {
     await FirebaseAuth.instance.signOut();
   }
   ```

6. **Helper Method for Error Handling**:
   ```dart
   String _mapFirebaseError(dynamic error) {
     if (error is FirebaseAuthException) {
       switch (error.code) {
         case 'user-not-found':
           return 'No user found with this email';
         case 'wrong-password':
           return 'Wrong password';
         case 'email-already-in-use':
           return 'Email already in use';
         // Add more cases as needed
         default:
           return error.message ?? 'Authentication failed';
       }
     }
     return error.toString();
   }
   ```

### 3. Enable Firebase Auth in the App

To switch to your Firebase implementation, change the `init` call in `main.dart`:

```dart
final authService = await AuthService.init(useFirebase: true);
```

## Testing Firebase Implementation

1. Test with debugging enabled to catch any errors
2. Ensure all authentication flows work:
   - Sign up with new account
   - Login with existing account
   - Auto-login for returning users
   - Logout

## Additional Features to Consider

- Password reset
- Email verification
- Social logins (Google, Facebook, etc.)
- Phone number authentication
- Multi-factor authentication

## Need Help?

If you need assistance, refer to:
- [Firebase Auth Documentation](https://firebase.flutter.dev/docs/auth/overview/)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter) 