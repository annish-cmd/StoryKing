/*
 * AUTH REPOSITORY INTERFACE
 * -----------------------
 * This abstract class defines the contract for authentication implementations.
 * 
 * Purpose:
 * - Acts as a blueprint for different authentication implementations
 * - Allows switching between local storage and Firebase without changing the UI
 * - Provides a consistent interface for authentication operations
 * 
 * Implementations:
 * - LocalAuthRepository: Uses SharedPreferences for local authentication (current)
 * - FirebaseAuthRepository: Will use Firebase Authentication (to be implemented)
 * 
 * Operations:
 * - getCurrentUser: Retrieves the currently logged in user
 * - login: Authenticates a user with email and password
 * - signUp: Registers a new user
 * - logout: Signs out the current user
 */

// import '../../models/user_model.dart';

// abstract class AuthRepository {
//   /// Initialize the authentication service
//   static Future<AuthRepository> init() async {
//     throw UnimplementedError('Subclasses must override init()');
//   }

//   Future<User?> getCurrentUser();

//   Future<User> login(String email, String password);

//   Future<User> signUp(User user);

//   Future<void> logout();
// }

// auth_repository.dart

import '../../models/user_model.dart';

/// Abstract class that defines the authentication repository interface
abstract class AuthRepository {
  /// Get the currently authenticated user or null if not authenticated
  Future<User?> getCurrentUser();

  /// Sign in with email and password
  /// Returns the User on success, or throws an exception on failure
  Future<User> login(String email, String password);

  /// Create a new user account
  /// Returns the created User on success, or throws an exception on failure
  Future<User> signup(String name, String email, String password);

  /// Sign out the current user
  Future<void> logout();

  /// Reset password
  Future<void> resetPassword(String email);
}
