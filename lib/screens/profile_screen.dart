/*
 * PROFILE SCREEN
 * ------------
 * Displays user information and account management options.
 * 
 * Main features:
 * - User profile information display
 * - Profile photo upload and management
 * - Name editing functionality
 * - Account settings management
 * - Navigation to help, about, and settings screens
 * - Logout functionality
 * 
 * UI elements:
 * - Profile photo with upload option
 * - User name and email display
 * - Settings menu with navigation options
 * - Edit name functionality
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/auth/auth_service.dart';
import 'auth_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic user;
  final AuthService authService;
  final Function toggleTheme;
  final Function(double) setTextScaleFactor;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.authService,
    required this.toggleTheme,
    required this.setTextScaleFactor,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadSavedName();

    // Initialize user name from user object if available
    if (widget.user != null) {
      try {
        _userName = widget.user.name ?? '';
      } catch (e) {
        // Handle case where user.name isn't accessible
        print('Error accessing user name: $e');
      }
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  // Future<void> _saveName(String name) async {

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('user_name', name);

  //   // Update the user object with the new name
  //   if (widget.user != null) {
  //     setState(() {
  //       widget.user.name = name;
  //     });
  //   }
  // }

  Future<void> _saveName(String name) async {
    setState(() {
      _isLoading = true;
      _userName = name; // Store locally in widget state
    });

    try {
      // 1. Save to SharedPreferences if you still want this
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      // 2. Update in Firebase
      if (widget.user != null) {
        final userId = widget.user.uid; // Make sure this property exists

        // Update in Firestore - adjust collection path as needed
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'name': name});

        // If using Firebase Auth, update display name there too
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

        // Don't try to set name directly on user object
        // _username = name; // This causes the error
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (savedName != null && mounted) {
      setState(() {
        _userName = savedName;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _saveProfileImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.titleTextStyle?.color,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6448FE),
                        Color(0xFF5FC6FF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6448FE).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _profileImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : Center(
                          child: Text(
                            _userName.isNotEmpty == true
                                ? widget.user.name[0].toUpperCase()
                                : '?',
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6448FE),
                                Color(0xFF5FC6FF),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.user?.name ?? 'User',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user?.email ?? 'email@example.com',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    context: context,
                    icon: Icons.edit_rounded,
                    title: 'Edit Name',
                    onTap: () => _showEditNameDialog(context),
                  ),
                  Divider(
                      color: isDark ? Colors.white12 : Colors.black12,
                      height: 1),
                  _buildProfileItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                      color: isDark ? Colors.white12 : Colors.black12,
                      height: 1),
                  _buildProfileItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            toggleTheme: widget.toggleTheme,
                            setTextScaleFactor: widget.setTextScaleFactor,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(
                      color: isDark ? Colors.white12 : Colors.black12,
                      height: 1),
                  _buildProfileItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildProfileItem(
                context: context,
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: () async {
                  await widget.authService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(
                          authService: widget.authService,
                          toggleTheme: widget.toggleTheme,
                          setTextScaleFactor: widget.setTextScaleFactor,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: widget.user?.name);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Edit Name',
            style: textTheme.titleLarge?.copyWith(
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter your new name",
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            style: textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    // Save the name to SharedPreferences and update user object
                    await _saveName(newName);

                    if (mounted) {
                      Navigator.of(context).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Name updated successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating name: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Save',
                style: textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : isDark
                          ? Colors.white.withOpacity(0.1)
                          : theme.primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : isDark
                          ? Colors.white70
                          : theme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: isDestructive
                      ? Colors.red
                      : theme.textTheme.titleMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (!isDestructive)
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItems() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _buildProfileItem(
          context: context,
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () => _showEditNameDialog(context),
        ),
        _buildProfileItem(
          context: context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  toggleTheme: widget.toggleTheme,
                  setTextScaleFactor: widget.setTextScaleFactor,
                ),
              ),
            );
          },
        ),
        _buildProfileItem(
          context: context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        _buildProfileItem(
          context: context,
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutScreen(),
              ),
            );
          },
        ),
        _buildProfileItem(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () async {
            await widget.authService.logout();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(
                    authService: widget.authService,
                    toggleTheme: widget.toggleTheme,
                    setTextScaleFactor: widget.setTextScaleFactor,
                  ),
                ),
              );
            }
          },
          isDestructive: true,
        ),
      ],
    );
  }
}
