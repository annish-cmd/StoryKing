/*
 * CUSTOM DRAWER
 * ------------
 * Main navigation drawer for the application.
 * 
 * Main features:
 * - User profile display in header
 * - Navigation links to main app sections
 * - External links to social media
 * - App sharing and rating options
 * - Logout functionality
 * 
 * UI components:
 * - Gradient header with user info
 * - Styled navigation menu items
 * - Attractive visual effects (shadows, gradients)
 * - Consistent branding with app theme
 */

import 'package:flutter/material.dart';
import '../widgets/default_icon.dart';
import '../services/auth/auth_service.dart';
import '../screens/auth_screen.dart';
import '../screens/favorites_screen.dart';
import '../services/tts_service.dart';
import '../screens/contact_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';

class CustomDrawer extends StatelessWidget {
  final dynamic user;
  final AuthService authService;
  final TTSService ttsService;
  final StorageService storageService;
  final Function toggleTheme;
  final Function(double)? setTextScaleFactor;

  const CustomDrawer({
    Key? key,
    required this.user,
    required this.authService,
    required this.ttsService,
    required this.storageService,
    required this.toggleTheme,
    this.setTextScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildDrawerItems(context),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6448FE),
              Color(0xFF5FC6FF),
            ],
            stops: [0.0, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6448FE).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            // App Logo/Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // App Name
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white],
              ).createShader(bounds),
              child: Text(
                'StoryKing',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // App tagline
            Text(
              'Create stories with your imagination',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            // Decorative design element
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItems(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerItem(
            context: context,
            icon: Icons.home_rounded,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            onTap: () async {
              // Show loading indicator
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Loading favorites...'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Load stories from storage
              // final storageService = StorageService();
              final allStories = await storageService.loadStories();

              // Filter only favorite stories
              final favoriteStories =
                  allStories.where((story) => story.isFavorite).toList();

              if (context.mounted) {
                // Navigate to favorites screen with the favorite stories
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      favoriteStories: favoriteStories,
                      ttsService: ttsService,
                    ),
                  ),
                );
              }
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.message,
            title: 'Contact Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.facebook,
            title: 'Facebook',
            onTap: () {
              launch('https://www.facebook.com/ItsMeAnnesh/');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.photo,
            title: 'Instagram',
            onTap: () {
              launch('https://www.instagram.com/theannishchauhan_____/');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.share_rounded,
            title: 'Share App',
            onTap: () {
              Share.share(
                  'Check out this awesome app! Share it with your friends! https://github.com/annish-cmd');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.star_rounded,
            title: 'Rate Us',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? Colors.red
                  : isDark
                      ? Colors.white
                      : theme.primaryColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDestructive
                      ? Colors.red
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            thickness: 1,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            isDestructive: true,
            onTap: () async {
              _logout(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'App Version 1.0.0',
              style: textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await authService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(
            authService: authService,
            toggleTheme: toggleTheme,
            setTextScaleFactor: setTextScaleFactor,
          ),
        ),
      );
    }
  }
}
