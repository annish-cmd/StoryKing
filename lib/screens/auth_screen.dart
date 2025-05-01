/*
 * AUTHENTICATION SCREEN
 * --------------------
 * This screen handles both login and registration UI for the app.
 * 
 * Key functionality:
 * 1. Login form - Email and password fields with validation
 * 2. Registration form - Name, email, password, and confirm password fields
 * 3. Form toggle - Switches between login and registration modes
 * 4. Form validation - Validates all input fields before submission
 * 5. Authentication - Handles login and registration logic via AuthService
 * 
 * UI features:
 * - Animated transitions between login and signup modes
 * - Form validation with helpful error messages
 * - Password visibility toggle
 * - Loading state during authentication
 * - Beautiful gradient background and card-based layout
 * 
 * Flow:
 * 1. Checks if user is already logged in on init
 * 2. If yes, redirects to MainScreen
 * 3. If no, displays login/signup form
 * 4. On successful authentication, navigates to MainScreen
 */

// import 'package:flutter/material.dart';
// import 'package:email_validator/email_validator.dart';
// import '../models/user_model.dart';
// import '../services/auth/auth_service.dart';
// import 'main_screen.dart';

// class AuthScreen extends StatefulWidget {
//   final AuthService authService;
//   final Function? toggleTheme;
//   final Function(double)? setTextScaleFactor;

//   const AuthScreen({
//     Key? key,
//     required this.authService,
//     this.toggleTheme,
//     this.setTextScaleFactor,
//   }) : super(key: key);

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   bool isLogin = true;
//   bool isLoading = false;
//   bool _isPasswordVisible = false;
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   late final AnimationController _animationController;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _animationController.forward();

//     // Check if user is already logged in
//     _checkCurrentUser();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void toggleAuth() {
//     setState(() {
//       isLogin = !isLogin;
//       _formKey.currentState?.reset();
//       _emailController.clear();
//       _passwordController.clear();
//       _confirmPasswordController.clear();
//       _nameController.clear();
//       _animationController.reset();
//       _animationController.forward();
//     });
//   }

//   Future<void> _checkCurrentUser() async {
//     final currentUser = await widget.authService.getCurrentUser();
//     if (currentUser != null && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MainScreen(
//             user: currentUser,
//             authService: widget.authService,
//             toggleTheme: widget.toggleTheme ?? () {},
//             setTextScaleFactor: widget.setTextScaleFactor ?? ((_) {}),
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _handleSubmit() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() => isLoading = true);

//       try {
//         if (isLogin) {
//           // Handle login
//           final user = await widget.authService.login(
//             _emailController.text.trim(),
//             _passwordController.text,
//           );
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MainScreen(
//                   user: user,
//                   authService: widget.authService,
//                   toggleTheme: widget.toggleTheme ?? () {},
//                   setTextScaleFactor: widget.setTextScaleFactor ?? ((_) {}),
//                 ),
//               ),
//             );
//           }
//         } else {
//           // Handle signup
//           final newUser = User(
//             name: _nameController.text.trim(),
//             email: _emailController.text.trim(),
//             password: _passwordController.text,
//           );
//           await widget.authService.signUp(newUser);
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MainScreen(
//                   user: newUser,
//                   authService: widget.authService,
//                   toggleTheme: widget.toggleTheme ?? () {},
//                   setTextScaleFactor: widget.setTextScaleFactor ?? ((_) {}),
//                 ),
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           // Show error in a more user-friendly way
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 e.toString().replaceAll('Exception: ', ''),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       } finally {
//         if (mounted) setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF6448FE),
//               Color(0xFF5FC6FF),
//             ],
//             stops: [0.0, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 50),
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Text(
//                       isLogin ? 'Welcome\nBack!' : 'Create\nAccount',
//                       style: const TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         height: 1.2,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 15,
//                             spreadRadius: 0,
//                             offset: Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             if (!isLogin)
//                               _buildTextField(
//                                 controller: _nameController,
//                                 hint: 'Full Name',
//                                 icon: Icons.person_outline,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your name';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             _buildTextField(
//                               controller: _emailController,
//                               hint: 'Email',
//                               icon: Icons.email_outlined,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your email';
//                                 }
//                                 if (!EmailValidator.validate(value)) {
//                                   return 'Please enter a valid email';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             _buildTextField(
//                               controller: _passwordController,
//                               hint: 'Password',
//                               icon: Icons.lock_outline,
//                               isPassword: true,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your password';
//                                 }
//                                 if (value.length < 6) {
//                                   return 'Password must be at least 6 characters';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             if (!isLogin)
//                               _buildTextField(
//                                 controller: _confirmPasswordController,
//                                 hint: 'Confirm Password',
//                                 icon: Icons.lock_outline,
//                                 isPassword: true,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please confirm your password';
//                                   }
//                                   if (value != _passwordController.text) {
//                                     return 'Passwords do not match';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             if (isLogin)
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: TextButton(
//                                   onPressed: () {
//                                     // TODO: Implement forgot password
//                                   },
//                                   child: const Text(
//                                     'Forgot Password?',
//                                     style: TextStyle(
//                                       color: Color(0xFF6448FE),
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               width: double.infinity,
//                               height: 55,
//                               child: ElevatedButton(
//                                 onPressed: isLoading ? null : _handleSubmit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF6448FE),
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   elevation: 5,
//                                 ),
//                                 child: isLoading
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : Text(
//                                         isLogin ? 'LOGIN' : 'SIGN UP',
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Center(
//                     child: TextButton(
//                       onPressed: toggleAuth,
//                       child: Text(
//                         isLogin
//                             ? 'Don\'t have an account? Sign Up'
//                             : 'Already have an account? Login',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     String? Function(String?)? validator,
//     TextEditingController? controller,
//     TextInputType? keyboardType,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             spreadRadius: 0,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword && !_isPasswordVisible,
//         keyboardType: keyboardType,
//         validator: validator,
//         style: const TextStyle(
//           color: Colors.black87,
//           fontSize: 16,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(
//             color: Colors.grey.shade400,
//             fontSize: 16,
//           ),
//           prefixIcon: Icon(
//             icon,
//             color: const Color(0xFF6448FE),
//             size: 22,
//           ),
//           suffixIcon: isPassword
//               ? IconButton(
//                   icon: Icon(
//                     _isPasswordVisible
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                     color: const Color(0xFF6448FE),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isPasswordVisible = !_isPasswordVisible;
//                     });
//                   },
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../services/auth/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final AuthService authService;
  final Function? toggleTheme;
  final Function(double)? setTextScaleFactor;

  const AuthScreen({
    Key? key,
    required this.authService,
    this.toggleTheme,
    this.setTextScaleFactor,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Check if user is already logged in
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void toggleAuth() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _checkCurrentUser() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/main_screen');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      try {
        if (isLogin) {
          // Login flow
          await widget.authService.login(
            _emailController.text.trim(),
            _passwordController.text,
          );

          // Show success dialog for login
          if (mounted) {
            await _showSuccessDialog(
                title: 'Login Successful',
                message: 'Welcome back to StoryKing!');
          }
        } else {
          // Signup flow
          await widget.authService.signup(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );

          // Show success dialog for account creation
          if (mounted) {
            await _showSuccessDialog(
                title: 'Account Created',
                message:
                    'Your StoryKing account has been created successfully!');
          }
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main_screen');
        }
      } catch (e) {
        if (mounted) {
          // Show simplified error messages
          String errorMessage = 'Authentication failed';

          // Extract the error message
          final errorString = e.toString().toLowerCase();

          if (errorString.contains('password') ||
              errorString.contains('credential') ||
              errorString.contains('user-not-found') ||
              errorString.contains('wrong password')) {
            errorMessage = 'Wrong Credentials';
          } else if (errorString.contains('email') &&
              errorString.contains('already')) {
            errorMessage = 'Email already in use';
          } else if (errorString.contains('network')) {
            errorMessage = 'Network error';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(
      {required String title, required String message}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6448FE),
                  Color(0xFF5FC6FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF6448FE),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: Color(0xFF6448FE),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6448FE),
              Color(0xFF5FC6FF),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      isLogin ? 'Welcome\nBack!' : 'Create\nAccount',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!isLogin)
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!EmailValidator.validate(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            if (!isLogin)
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hint: 'Confirm Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            if (isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF6448FE),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6448FE),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        isLogin ? 'LOGIN' : 'SIGN UP',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: toggleAuth,
                      child: Text(
                        isLogin
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Login',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6448FE),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF6448FE),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
