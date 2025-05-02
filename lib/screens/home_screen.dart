/*
 * HOME SCREEN
 * ----------
 * This is the main content screen of the application, where users can
 * generate and interact with stories.
 * 
 * Key functionality:
 * 1. Story generation - Creates stories using AI based on user input
 * 2. Text-to-speech - Reads stories aloud with voice synthesis
 * 3. Story management - View, favorite, and organize generated stories
 * 4. Local storage - Persists generated stories between app sessions
 * 
 * Service integrations:
 * - Story Service: Connects to AI backend for story generation (API Key required)
 * - TTS Service: Connects to Elevenlabs API for text-to-speech (API Key required)
 * - Storage Service: Local persistence of generated stories
 * 
 * UI features:
 * - Animated buttons and interactions
 * - Loading states during story generation
 * - Story cards with playback controls
 * - Error handling for failed API requests
 */

import 'package:android_app/services/storage/firebase_storage_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/story_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../models/story.dart';
import '../screens/settings_screen.dart';
import 'dart:math' as math;
import 'favorites_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  final dynamic user;
  final TTSService ttsService;
  final Function toggleTheme;
  final Function(double) setTextScaleFactor;

  const HomeScreen({
    Key? key,
    this.user,
    required this.ttsService,
    required this.toggleTheme,
    required this.setTextScaleFactor,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _storyController;
  List<Story> generatedStories = [];
  bool isLoading = false;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  late StoryService _storyService;
  late TTSService _ttsService;
  final StorageService _storageService = StorageService.instance;
  String? _currentlyPlayingStoryId;

  @override
  void initState() {
    super.initState();
    _storyController = TextEditingController();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );
    _storyService = StoryService(
      apiKey: dotenv.env['OPENROUTER_API_KEY'] ??
          '', // Use environment variable for OpenRouter API key
    );
    _ttsService = widget.ttsService; // Use the provided TTSService
    _loadSavedStories();
  }

  Future<void> _loadSavedStories() async {
    try {
      final stories = await _storageService.loadStories();
      setState(() {
        generatedStories = stories;
      });
    } catch (e) {
      print('Error loading stories: $e');
    }
  }

  Future<void> _saveStories() async {
    try {
      await _storageService.saveStories(generatedStories);
    } catch (e) {
      print('Error saving stories: $e');
    }
  }

  @override
  void dispose() {
    _storyController.dispose();
    _buttonController.dispose();
    _storyService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _onGeneratePressed() async {
    final prompt = _storyController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final story = await _storyService.generateStory(prompt, userId: userId);
      setState(() {
        generatedStories.insert(0, story);
        _storyController.clear();
      });
      // Save stories after generating a new one
      await _saveStories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Poor Internet Connection'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteStory(int index) async {
    final deletedStory = generatedStories[index];
    setState(() {
      generatedStories.removeAt(index);
    });
    await _saveStories();

    await _storageService.deleteStory(deletedStory.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Story deleted',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        // width: MediaQuery.of(context).size.width * 0.45,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 20,
          right: 20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF6C4FFF),
          onPressed: () async {
            setState(() {
              generatedStories.insert(index, deletedStory);
            });
            await _saveStories();
          },
        ),
      ),
    );
  }

  Future<void> _editTitle(Story story) async {
    final TextEditingController titleController =
        TextEditingController(text: story.title);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Title',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C4FFF), width: 1),
                ),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                    hintText: 'Enter new title...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      final newTitle = titleController.text.trim();
                      if (newTitle.isNotEmpty) {
                        setState(() {
                          final index = generatedStories.indexOf(story);
                          generatedStories[index] = Story(
                            userId: story.userId,
                            id: story.id,
                            title: newTitle,
                            content: story.content,
                            createdAt: story.createdAt,
                            isPlaying: story.isPlaying,
                          );
                        });
                        _saveStories();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF6C4FFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePlayback(Story story) async {
    try {
      if (_currentlyPlayingStoryId == story.id) {
        // Stop current playback
        await _ttsService.stop();
        setState(() {
          _currentlyPlayingStoryId = null;
          story.isPlaying = false;
        });
      } else {
        // Stop any current playback
        if (_currentlyPlayingStoryId != null) {
          final currentStory = generatedStories.firstWhere(
            (s) => s.id == _currentlyPlayingStoryId,
          );
          await _ttsService.stop();
          setState(() {
            currentStory.isPlaying = false;
          });
        }

        // Start new playback
        setState(() {
          _currentlyPlayingStoryId = story.id;
          story.isPlaying = true;
        });

        await _ttsService.play(story.content);

        // Update state when playback completes
        setState(() {
          _currentlyPlayingStoryId = null;
          story.isPlaying = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentlyPlayingStoryId = null;
        story.isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Poor Internet Connection'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Story story) async {
    setState(() {
      final index = generatedStories.indexOf(story);
      generatedStories[index] = Story(
        id: story.id,
        userId: story.userId,
        title: story.title,
        content: story.content,
        createdAt: story.createdAt,
        isPlaying: story.isPlaying,
        isFavorite: !story.isFavorite,
      );
    });
    await _saveStories();
  }

  Future<void> _navigateToFavorites() async {
    final favoriteStories =
        generatedStories.where((story) => story.isFavorite).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteStories: favoriteStories,
          ttsService: _ttsService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 72,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Text(
                    'StoryKing',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.appBarTheme.foregroundColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_border,
                              color: theme.appBarTheme.foregroundColor),
                          splashRadius: 24,
                          onPressed: _navigateToFavorites,
                          tooltip: 'Favorites',
                        ),
                        if (generatedStories
                            .where((story) => story.isFavorite)
                            .isNotEmpty)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${generatedStories.where((story) => story.isFavorite).length}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.settings_outlined,
                          color: theme.appBarTheme.foregroundColor),
                      splashRadius: 24,
                      onPressed: () {
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _storyController,
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  height: 1.5,
                ),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter an idea for your story...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                    height: 1.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTapDown: (_) => _buttonController.forward(),
              onTapUp: (_) => _buttonController.reverse(),
              onTapCancel: () => _buttonController.reverse(),
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6C4FFF),
                        Color(0xFF4DA7FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C4FFF).withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _onGeneratePressed,
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Generate',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Your Generated Stories',
              style: textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: generatedStories.length,
                itemBuilder: (context, index) {
                  return _buildStoryListItem(
                      context, generatedStories[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryListItem(BuildContext context, Story story, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(story.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteStory(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _showStoryDetailDialog(context, story);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          story.isPlaying
                              ? Icons.stop_circle
                              : Icons.play_circle,
                          color: const Color(0xFF6C4FFF),
                          size: 28,
                        ),
                        onPressed: () => _togglePlayback(story),
                      ),
                      IconButton(
                        icon: Icon(
                          story.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: story.isFavorite
                              ? Colors.redAccent
                              : isDark
                                  ? Colors.white54
                                  : Colors.grey[600],
                          size: 24,
                        ),
                        onPressed: () => _toggleFavorite(story),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStoryDetailDialog(BuildContext context, Story story) {
    showDialog(
      context: context,
      builder: (context) {
        final dialogTheme = Theme.of(context);
        final isDialogDark = dialogTheme.brightness == Brightness.dark;
        return Dialog(
          backgroundColor:
              isDialogDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6C4FFF),
                        Color(0xFF4DA7FF),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          story.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () => _toggleFavorite(story),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      story.content,
                      style: TextStyle(
                        color: isDialogDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStoryActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        onTap: () {
                          Navigator.pop(context);
                          _editTitle(story);
                        },
                        isDark: isDialogDark,
                      ),
                      _buildStoryActionButton(
                        icon: story.isPlaying ? Icons.stop : Icons.play_arrow,
                        label: story.isPlaying ? 'Stop' : 'Play',
                        onTap: () {
                          _togglePlayback(story);
                          Navigator.pop(context);
                        },
                        isDark: isDialogDark,
                      ),
                      _buildStoryActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () {
                          Share.share(
                            'Check out this story from StoryKing!\n\n${story.title}\n\n${story.content}',
                            subject: story.title,
                          );
                        },
                        isDark: isDialogDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.grey[800],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[800],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Other drawer items...
          _buildDrawerItem(
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            onTap: () {
              final favoriteStories =
                  generatedStories.where((story) => story.isFavorite).toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    favoriteStories: favoriteStories,
                    ttsService: _ttsService,
                  ),
                ),
              );
            },
          ),
          // Other drawer items...
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 2.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
