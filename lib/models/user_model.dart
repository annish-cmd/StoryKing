/*
 * USER MODEL
 * ---------
 * This model represents a user in the application and handles 
 * serialization/deserialization of user data.
 * 
 * Key properties:
 * - name: The user's full name
 * - email: The user's email address (used for login)
 * - password: The user's password (in a real app, this should be hashed)
 * 
 * Key functionality:
 * - toJson(): Converts user object to JSON for storage/transmission
 * - fromJson(): Creates user object from JSON data
 * 
 * Usage:
 * - User authentication (login/signup)
 * - User profile management
 * - Session management
 * 
 * Note: In a production environment, sensitive data like passwords
 * should never be stored in plain text and should be properly secured.
 */

// class User {
//   String name;
//   final String email;
//   final String password;
//   // This should not be stored after signup/login

//   User({
//     required this.name,
//     required this.email,
//     required this.password,
//   });

//   User copyWith({
//     String? name,
//     String? email,
//     String? password,
//   }) {
//     return User(
//       name: name ?? this.name,
//       email: email ?? this.email,
//       password: password ?? this.password,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       // 'password': password,
//       // Do not include password in the JSON representation
//     };
//   }

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       name: json['name'] as String,
//       email: json['email'] as String,
//       password: json['password'] as String,
//       // password: '',
//     );
//   }
// }

class User {
  final String uid; // Unique identifier for the user
  final String name;
  final String email;
  final String password; // Only used during signup/login, not stored in model

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.password = '',
  });

  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        uid: json['uid'],
        name: json['name'],
        email: json['email'],
      );
}
