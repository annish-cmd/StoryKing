/*
 * MAIN SCREEN
 * ----------
 * This is the primary screen of the application after successful authentication.
 * It serves as a container for the main functionality screens of the app.
 * 
 * Key functionality:
 * 1. Bottom navigation bar for switching between main sections (Home, Profile)
 * 2. Drawer menu for additional navigation options
 * 3. Manages the state of the current active screen
 * 4. Custom UI styling with animations and gradients
 * 
 * Navigation structure:
 * - Home screen: Main content area for story generation and browsing
 * - Profile screen: User profile management and settings
 * - Drawer menu: Additional navigation to favorites, settings, etc.
 * 
 * Design features:
 * - Custom animated bottom navigation with selected state indicator
 * - Custom drawer menu with user information
 * - Smooth transitions between screens
 * - Gradient styling for UI elements
 */

import 'package:android_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_drawer.dart';
import '../services/auth/auth_service.dart';
import '../services/tts_service.dart';
import 'package:android_app/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainScreen extends StatefulWidget {
  // final dynamic user;
  final AuthService authService;
  final Function toggleTheme;
  final Function(double) setTextScaleFactor;

  const MainScreen({
    Key? key,
    // required this.user,
    required this.authService,
    required this.toggleTheme,
    required this.setTextScaleFactor,
  }) : super(key: key);

  @override
  // _MainScreenState createState() => _MainScreenState();
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TTSService _ttsService;
  late StorageService _storageService;

  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize TTS service with API key from environment variables
    _ttsService = TTSService(
      apiKey: dotenv.env['ELEVENLABS_API_KEY'] ??
          '', // Use environment variable for ElevenLabs API key
    );

    _loadUser();
    _storageService = StorageService.instance;
  }

  Future<void> _loadUser() async {
    try {
      final user = await widget.authService.getCurrentUser();

      if (mounted) {
        setState(() {
          currentUser = user;
          isLoading = false;

          _screens = [
            HomeScreen(
              user: currentUser,
              ttsService: _ttsService,
              toggleTheme: widget.toggleTheme,
              setTextScaleFactor: widget.setTextScaleFactor,
            ),
            ProfileScreen(
              user: currentUser,
              authService: widget.authService,
              toggleTheme: widget.toggleTheme,
              setTextScaleFactor: widget.setTextScaleFactor,
            ),
          ];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        user: currentUser,
        storageService: _storageService,
        authService: widget.authService,
        ttsService: _ttsService,
        toggleTheme: widget.toggleTheme,
        setTextScaleFactor: widget.setTextScaleFactor,
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_currentIndex == 0) // Only show drawer icon on Home screen
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _currentIndex == 0 ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6448FE),
                        Color(0xFF5FC6FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6448FE).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          // Close drawer if it's open when switching to Profile
          if (index == 1 && _scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF6448FE),
                    Color(0xFF5FC6FF),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white60
                      : Colors.grey[600],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
