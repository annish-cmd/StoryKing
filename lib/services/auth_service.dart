// /*
//  * AUTHENTICATION SERVICE
//  * ---------------------
//  * This service handles all authentication-related operations in the app.
//  * 
//  * Key functionality:
//  * 1. User login - Authenticates existing users
//  * 2. User signup - Registers new users
//  * 3. Session management - Checks for current logged-in user
//  * 4. Logout - Clears user session data
//  * 
//  * Implementation details:
//  * - Currently uses SharedPreferences for local storage of user credentials
//  * - In a production environment, this would connect to a backend API
//  * - Simulates network delays for realistic behavior
//  * - Provides proper error handling for authentication failures
//  * 
//  * Note: This is a simplified authentication implementation. In a production
//  * environment, passwords should be securely hashed and not stored in plain text.
//  */

// // for local storage, use this

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_model.dart';

// class AuthService {
//   static const String USER_KEY = 'user_data';
//   final SharedPreferences _prefs;

//   AuthService._({required SharedPreferences prefs}) : _prefs = prefs;

//   static Future<AuthService> init() async {
//     final prefs = await SharedPreferences.getInstance();
//     return AuthService._(prefs: prefs);
//   }

//   Future<User?> getCurrentUser() async {
//     final userStr = _prefs.getString(USER_KEY);
//     if (userStr != null) {
//       try {
//         final userData = json.decode(userStr);
//         return User(
//           name: userData['name'],
//           email: userData['email'],
//           password: userData['password'],
//         );
//       } catch (e) {
//         print('Error parsing user data: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   Future<User> login(String email, String password) async {
//     // Simulate API call delay
//     await Future.delayed(const Duration(seconds: 1));

//     // In a real app, validate against backend
//     if (email.isEmpty || password.isEmpty) {
//       throw Exception('Email and password are required');
//     }

//     // Create a user object
//     final user = User(
//       name: email.split('@')[0], // Simple name from email
//       email: email,
//       password: password,
//     );

//     // Save user data
//     await _saveUser(user);
//     return user;
//   }

//   Future<User> signUp(User user) async {
//     // Simulate API call delay
//     await Future.delayed(const Duration(seconds: 1));

//     // In a real app, validate against backend
//     if (user.email.isEmpty || user.password.isEmpty) {
//       throw Exception('Email and password are required');
//     }

//     // Save user data
//     await _saveUser(user);
//     return user;
//   }

//   Future<void> logout() async {
//     await _prefs.remove(USER_KEY);
//   }

//   Future<void> _saveUser(User user) async {
//     final userData = {
//       'name': user.name,
//       'email': user.email,
//       'password': user.password,
//     };
//     await _prefs.setString(USER_KEY, json.encode(userData));
//   }
// }
