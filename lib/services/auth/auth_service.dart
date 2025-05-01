/*
 * AUTHENTICATION SERVICE PROVIDER
 * ----------------------------
 * This service acts as a provider for authentication implementations.
 * 
 * Key functionality:
 * - Provides a single point of access for authentication
 * - Allows switching between local storage and Firebase implementations
 * - Maintains backward compatibility with existing code
 * 
 * Usage:
 * - For current local auth: AuthService.init()
 * - To use Firebase auth: AuthService.init(useFirebase: true)
 * 
 * Note: This implementation makes it easy to switch between authentication
 * methods without changing the UI code.
 */

// import 'auth_repository.dart';
// import 'local_auth_repository.dart';
// import 'firebase_auth_repository.dart';
// import '../../models/user_model.dart';

// class AuthService {
//   final AuthRepository _repository;

//   AuthService._(this._repository);

//   /// Initialize the authentication service
//   /// Set useFirebase to true to use Firebase authentication (when ready)
//   static Future<AuthService> init({bool useFirebase = true}) async {
//     final repository = useFirebase
//         ? await FirebaseAuthRepository.init()
//         : await LocalAuthRepository.init();
//     return AuthService._(repository);
//   }

//   /// Get the currently logged in user, or null if not logged in
//   Future<User?> getCurrentUser() => _repository.getCurrentUser();

//   /// Login with email and password
//   Future<User> login(String email, String password) =>
//       _repository.login(email, password);

//   /// Register a new user
//   Future<User> signUp(User user) => _repository.signUp(user);

//   /// Logout the current user
//   Future<void> logout() => _repository.logout();
// }

import '../../models/user_model.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';
import 'local_auth_repository.dart';

/// Authentication Service Provider
/// This service acts as a facade for authentication operations throughout the app.
/// It abstracts the underlying implementation (Firebase) and provides a clean API
/// for authentication functions.
class AuthService {
  static AuthService? _instance;
  final AuthRepository _repository;

  /// Private constructor with repository dependency
  AuthService._({required AuthRepository repository})
      : _repository = repository;

  /// Initialize the authentication service
  /// Must be called before accessing any authentication functions
  /// If useFirebase is true, Firebase auth will be used, otherwise local auth
  static Future<AuthService> init({bool useFirebase = true}) async {
    if (_instance == null) {
      AuthRepository repository;

      if (useFirebase) {
        // Note: Firebase.initializeApp() should be called in main.dart before this
        repository = FirebaseAuthRepository();
      } else {
        repository = await LocalAuthRepository.init();
      }

      _instance = AuthService._(repository: repository);
    }
    return _instance!;
  }

  /// Get the singleton instance of AuthService
  static AuthService get instance {
    if (_instance == null) {
      throw Exception(
          'AuthService must be initialized before accessing instance');
    }
    return _instance!;
  }

  /// Get the currently authenticated user
  /// Returns null if no user is authenticated
  Future<User?> getCurrentUser() => _repository.getCurrentUser();

  /// Sign in with email and password
  /// Returns the User on success, or throws an exception on failure
  Future<User> login(String email, String password) =>
      _repository.login(email, password);

  /// Create a new user account
  /// Returns the created User on success, or throws an exception on failure
  Future<User> signup(String name, String email, String password) =>
      _repository.signup(name, email, password);

  /// Sign out the current user
  Future<void> logout() => _repository.logout();

  /// Reset password for the given email
  /// Sends a password reset email
  Future<void> resetPassword(String email) => _repository.resetPassword(email);
}
