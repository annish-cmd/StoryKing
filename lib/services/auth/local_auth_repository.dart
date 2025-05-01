/*
 * LOCAL AUTH REPOSITORY
 * -------------------
 * Implementation of AuthRepository that uses SharedPreferences for local storage.
 * 
 * This implementation:
 * - Stores user credentials locally on the device
 * - Simulates network delays for API calls
 * - Handles login, signup, and session management
 * 
 * Note: This implementation is for development/demo purposes.
 * In production, authentication should use secure backend services.
 */

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/user_model.dart';
// import 'auth_repository.dart';

// class LocalAuthRepository implements AuthRepository {
//   static const String USER_KEY = 'user_data';
//   final SharedPreferences _prefs;

//   LocalAuthRepository._({required SharedPreferences prefs}) : _prefs = prefs;

//   @override
//   static Future<LocalAuthRepository> init() async {
//     final prefs = await SharedPreferences.getInstance();
//     return LocalAuthRepository._(prefs: prefs);
//   }

//   @override
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

//   @override
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

//   @override
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

//   @override
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

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import 'auth_repository.dart';

/// Local implementation of the AuthRepository interface using SharedPreferences
class LocalAuthRepository implements AuthRepository {
  static const String _userKey = 'user_data';
  static const String _usersCollectionKey = 'local_users';
  final SharedPreferences _prefs;

  /// Private constructor with required SharedPreferences
  LocalAuthRepository._({required SharedPreferences prefs}) : _prefs = prefs;

  /// Factory method to initialize the repository
  static Future<LocalAuthRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalAuthRepository._(prefs: prefs);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final userData = json.decode(userStr);
        return User(
          uid: userData['uid'],
          name: userData['name'],
          email: userData['email'],
        );
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get stored users
    final usersJson = _prefs.getString(_usersCollectionKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    // Check if user exists with matching email
    User? matchedUser;
    users.forEach((uid, userData) {
      if (userData['email'] == email && userData['password'] == password) {
        matchedUser = User(
          uid: uid,
          name: userData['name'],
          email: userData['email'],
        );
      }
    });

    if (matchedUser != null) {
      // Save as current user
      await _saveCurrentUser(matchedUser!);

      // Update last login
      final now = DateTime.now().toIso8601String();
      users[matchedUser!.uid] = {
        ...users[matchedUser!.uid],
        'lastLogin': now,
      };
      await _prefs.setString(_usersCollectionKey, json.encode(users));

      return matchedUser!;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get stored users
    final usersJson = _prefs.getString(_usersCollectionKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    // Check if email already exists
    final emailExists =
        users.values.any((userData) => userData['email'] == email);

    if (emailExists) {
      throw Exception('Email already in use');
    }

    // Create new user
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    final newUser = User(
      uid: uid,
      name: name,
      email: email,
    );

    // Save user in collection
    users[uid] = {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': now,
      'lastLogin': now,
    };

    await _prefs.setString(_usersCollectionKey, json.encode(users));

    // Save as current user
    await _saveCurrentUser(newUser);

    return newUser;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_userKey);
  }

  @override
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get stored users
    final usersJson = _prefs.getString(_usersCollectionKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    // Check if email exists
    bool emailFound = false;
    users.forEach((uid, userData) {
      if (userData['email'] == email) {
        emailFound = true;
      }
    });

    if (!emailFound) {
      throw Exception('No user found with this email');
    }

    // In a real app, you would send an email here
    // For local implementation, we just simulate success
    return;
  }

  /// Helper method to save current user to SharedPreferences
  Future<void> _saveCurrentUser(User user) async {
    final userData = {
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
    };
    await _prefs.setString(_userKey, json.encode(userData));
  }
}
