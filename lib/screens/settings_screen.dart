/*
 * SETTINGS SCREEN
 * -------------
 * Manages user preferences and application settings.
 * 
 * Main settings:
 * - Theme options (dark/light mode)
 * - Audio playback preferences
 * - Language selection
 * - Text size adjustment
 * - Notification toggles
 * 
 * Features:
 * - Persistent settings via SharedPreferences
 * - Reset options for defaults
 * - Cache clearing functionality
 * - Beautiful UI with custom dialogs
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function toggleTheme;
  final Function(double) setTextScaleFactor;

  const SettingsScreen({
    Key? key,
    required this.toggleTheme,
    required this.setTextScaleFactor,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _autoPlay = false;
  final String _selectedLanguage = 'English';
  double _textSize = 16.0;
  final String _selectedVoice = 'Female';
  bool _highQualityAudio = true;
  bool _saveOffline = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _loadDarkModePreference();
    await _loadTextSizePreference();
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode =
          prefs.getBool('darkMode') ?? true; // Default to true if not set
      print('Settings loaded darkMode: $_darkMode'); // Debug statement
    });
  }

  Future<void> _loadTextSizePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _textSize = prefs.getDouble('textScaleFactor') ?? 1.0;
        _textSize = _textSize * 16.0; // Convert scale factor to text size in sp
        print('Settings loaded textSize: $_textSize'); // Debug statement
      });
    } catch (e) {
      print('Error loading textSize preference: $e');
    }
  }

  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    print('Settings saved darkMode: $value'); // Debug statement
  }

  Future<void> _saveTextSizePreference(double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      double scaleFactor = value / 16.0; // Convert from sp to scale factor
      await prefs.setDouble('textScaleFactor', scaleFactor);
      widget.setTextScaleFactor(scaleFactor); // Update global text scale
      print('Settings saved textScaleFactor: $scaleFactor'); // Debug statement
    } catch (e) {
      print('Error saving textSize preference: $e');
    }
  }

  void _toggleDarkMode(bool value) async {
    // value here is the new light mode state (opposite of dark mode)
    setState(() {
      _darkMode = !value; // Convert from light mode to dark mode
    });
    await _saveDarkModePreference(_darkMode);
    widget.toggleTheme(); // Call parent's toggle theme
  }

  void _setTextSize(double value) async {
    setState(() {
      _textSize = value;
    });
    await _saveTextSizePreference(value);
  }

  void _resetSettings() {
    setState(() {
      _notificationsEnabled = true;
      _darkMode = true;
      _autoPlay = false;
      _textSize = 16.0;
      _highQualityAudio = true;
      _saveOffline = false;
    });
    _saveDarkModePreference(_darkMode);
    _saveTextSizePreference(_textSize); // Also reset text size
    widget.setTextScaleFactor(1.0); // Reset global text scale factor
  }

  Future<void> _clearCache() async {
    // Logic to clear only story-related data goes here
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'storyData'); // Replace 'storyData' with the actual key used for story data
    print('Story data cleared'); // Debug statement
  }

  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _darkMode ? Colors.redAccent : Colors.red,
                  _darkMode ? Colors.red[700]! : Colors.red[400]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clear Cache',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to clear the cache? This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          Text('Clear', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        _clearCache();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVoiceSelectionComingSoon() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: isDark ? Colors.white : Colors.black, size: 30),
                    SizedBox(width: 10),
                    Text('Voice Selection',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'This feature will be available soon. Stay tuned!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text('OK',
                      style: TextStyle(
                          color:
                              isDark ? Colors.grey[400] : theme.primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpgradeComingSoon() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.star,
                        color: isDark ? Colors.yellow : Colors.orange,
                        size: 30),
                    SizedBox(width: 10),
                    Text('Premium Upgrade',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'The Premium App will be available soon. Stay tuned for updates!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text('OK',
                      style: TextStyle(
                          color:
                              isDark ? Colors.grey[400] : theme.primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResetSettingsConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red,
                  Colors.red[700]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reset All Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  'Are you sure you want to reset all settings to default values?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reset All',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _resetSettings();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('All settings have been reset'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[700],
          fontSize: _textSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    List<Color>? gradientColors,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradientColors != null
                  ? LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: gradientColors == null
                  ? theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : theme.primaryColor.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: gradientColors != null
                  ? Colors.white
                  : theme.brightness == Brightness.dark
                      ? Colors.white
                      : theme.primaryColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: _textSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    fontSize: _textSize - 2,
                  ),
                )
              : null,
          trailing: trailing,
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged, ThemeData theme) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF6C4FFF),
      activeTrackColor: const Color(0xFF6C4FFF).withOpacity(0.3),
      inactiveThumbColor: theme.brightness == Brightness.dark
          ? Colors.grey[400]
          : Colors.grey[300],
      inactiveTrackColor: theme.brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[300],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.foregroundColor,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('App Preferences', theme),
            _buildSettingItem(
              title: 'Light Mode',
              icon: Icons.light_mode_rounded,
              trailing: _buildSwitch(!_darkMode, (value) {
                _toggleDarkMode(value);
              }, theme),
              gradientColors: [
                const Color(0xFF6C4FFF),
                const Color(0xFF4DA7FF)
              ],
              theme: theme,
            ),
            _buildSettingItem(
              title: 'Text Size',
              icon: Icons.text_fields_rounded,
              subtitle: '${_textSize.round()}sp',
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: _textSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  activeColor: const Color(0xFF6C4FFF),
                  inactiveColor: Colors.grey[800],
                  onChanged: (value) {
                    _setTextSize(value);
                  },
                ),
              ),
              theme: theme,
            ),
            _buildSettingItem(
              title: 'Language',
              icon: Icons.language_rounded,
              subtitle: _selectedLanguage,
              onTap: () {
                // Show language selection dialog
              },
              theme: theme,
            ),
            _buildSectionHeader('Story Playback', theme),
            _buildSettingItem(
              title: 'Auto-play Stories',
              icon: Icons.play_circle_outline_rounded,
              trailing: _buildSwitch(_autoPlay, (value) {
                setState(() => _autoPlay = value);
              }, theme),
              theme: theme,
            ),
            _buildSettingItem(
              title: 'Voice Selection',
              icon: Icons.record_voice_over_rounded,
              subtitle: _selectedVoice,
              onTap: () {
                _showVoiceSelectionComingSoon(); // Show coming soon dialog
              },
              theme: theme,
            ),
            _buildSettingItem(
              title: 'High Quality Audio',
              icon: Icons.high_quality_rounded,
              trailing: _buildSwitch(_highQualityAudio, (value) {
                setState(() => _highQualityAudio = value);
              }, theme),
              gradientColors: [
                const Color(0xFF4DA7FF),
                const Color(0xFF6C4FFF)
              ],
              theme: theme,
            ),
            _buildSectionHeader('Storage & Data', theme),
            _buildSettingItem(
              title: 'Save Stories Offline',
              icon: Icons.offline_pin_rounded,
              trailing: _buildSwitch(_saveOffline, (value) {
                setState(() => _saveOffline = value);
              }, theme),
              theme: theme,
            ),
            _buildSettingItem(
              title: 'Clear Cache',
              icon: Icons.cleaning_services_rounded,
              subtitle: 'Free up space by clearing cached data',
              onTap: () {
                _showClearCacheConfirmation(); // Show confirmation dialog
              },
              theme: theme,
            ),
            _buildSectionHeader('Notifications', theme),
            _buildSettingItem(
              title: 'Push Notifications',
              icon: Icons.notifications_rounded,
              trailing: _buildSwitch(_notificationsEnabled, (value) {
                setState(() => _notificationsEnabled = value);
              }, theme),
              theme: theme,
            ),
            _buildSettingItem(
              title: 'Email Notifications',
              icon: Icons.mail_outline_rounded,
              subtitle: 'Receive updates and newsletters',
              onTap: () {
                // Show email preferences dialog
              },
              theme: theme,
            ),
            _buildSectionHeader('Premium Features', theme),
            _buildSettingItem(
              title: 'Upgrade to Premium',
              icon: Icons.workspace_premium_rounded,
              subtitle: 'Unlock all premium features',
              gradientColors: [
                const Color(0xFFFFD700),
                const Color(0xFFFFA500)
              ],
              onTap: () {
                _showUpgradeComingSoon(); // Show coming soon dialog
              },
              theme: theme,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showResetSettingsConfirmation(); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Reset All Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
