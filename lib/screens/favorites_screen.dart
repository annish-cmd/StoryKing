/*
 * FAVORITES SCREEN
 * --------------
 * Displays user's favorite stories in a dedicated screen.
 * 
 * Main features:
 * - Lists all stories marked as favorites
 * - Provides playback functionality for stories
 * - Shows empty state when no favorites exist
 * - Displays story title and preview content
 * - Allows removing items from favorites
 * 
 * UI elements:
 * - Gradient background with card-based layout
 * - Play/stop buttons for audio playback
 * - Beautiful animations and visual effects
 */

// import 'package:flutter/material.dart';
// import '../models/story.dart';
// import '../services/tts_service.dart';
// import '../services/storage_service.dart';

// class FavoritesScreen extends StatefulWidget {
//   final List<Story> favoriteStories;
//   final TTSService ttsService;

//   const FavoritesScreen(
//       {Key? key, required this.favoriteStories, required this.ttsService})
//       : super(key: key);

//   @override
//   _FavoritesScreenState createState() => _FavoritesScreenState();
// }

// class _FavoritesScreenState extends State<FavoritesScreen> {
//   late List<Story> _favoriteStories;
//   String? _currentlyPlayingStoryId;
//   final StorageService _storageService = StorageService();

//   @override
//   void initState() {
//     super.initState();
//     _favoriteStories = List.from(widget.favoriteStories);

//     // Listen for when TTS playback completes
//     widget.ttsService.positionStream?.listen((position) {
//       // Update UI when playback completes
//       if (!widget.ttsService.isPlaying && _currentlyPlayingStoryId != null) {
//         setState(() {
//           final storyIndex = _favoriteStories
//               .indexWhere((s) => s.id == _currentlyPlayingStoryId);
//           if (storyIndex != -1) {
//             _favoriteStories[storyIndex] =
//                 _favoriteStories[storyIndex].copyWith(isPlaying: false);
//           }
//           _currentlyPlayingStoryId = null;
//         });
//       }
//     });
//   }

//   Future<void> _togglePlayback(Story story) async {
//     try {
//       if (_currentlyPlayingStoryId == story.id) {
//         // Stop current playback
//         await widget.ttsService.stop();
//         setState(() {
//           _currentlyPlayingStoryId = null;
//           final storyIndex = _favoriteStories.indexOf(story);
//           _favoriteStories[storyIndex] = story.copyWith(isPlaying: false);
//         });
//       } else {
//         // Stop any current playback
//         if (_currentlyPlayingStoryId != null) {
//           final currentStoryIndex = _favoriteStories.indexWhere(
//             (s) => s.id == _currentlyPlayingStoryId,
//           );
//           if (currentStoryIndex != -1) {
//             await widget.ttsService.stop();
//             setState(() {
//               _favoriteStories[currentStoryIndex] =
//                   _favoriteStories[currentStoryIndex]
//                       .copyWith(isPlaying: false);
//             });
//           }
//         }

//         // Start new playback
//         setState(() {
//           _currentlyPlayingStoryId = story.id;
//           final storyIndex = _favoriteStories.indexOf(story);
//           _favoriteStories[storyIndex] = story.copyWith(isPlaying: true);
//         });

//         await widget.ttsService.speak(story.content);

//         // Update state when playback completes
//         setState(() {
//           _currentlyPlayingStoryId = null;
//           final storyIndex = _favoriteStories.indexOf(story);
//           if (storyIndex != -1) {
//             _favoriteStories[storyIndex] =
//                 _favoriteStories[storyIndex].copyWith(isPlaying: false);
//           }
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _currentlyPlayingStoryId = null;
//         final storyIndex = _favoriteStories.indexOf(story);
//         if (storyIndex != -1) {
//           _favoriteStories[storyIndex] =
//               _favoriteStories[storyIndex].copyWith(isPlaying: false);
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to play audio: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _removeFromFavorites(Story story) async {
//     // First stop playback if this story is currently playing
//     if (_currentlyPlayingStoryId == story.id) {
//       await widget.ttsService.stop();
//       _currentlyPlayingStoryId = null;
//     }

//     // Create a modified version of the story with isFavorite = false
//     final updatedStory = story.copyWith(isFavorite: false, isPlaying: false);

//     // Remove from local list
//     setState(() {
//       _favoriteStories.removeWhere((s) => s.id == story.id);
//     });

//     // Update in storage by loading all stories, updating this one, and saving back
//     final allStories = await _storageService.loadStories();
//     final storyIndex = allStories.indexWhere((s) => s.id == story.id);
//     if (storyIndex != -1) {
//       allStories[storyIndex] = updatedStory;
//       await _storageService.saveStories(allStories);
//     }

//     // Show confirmation
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Removed from favorites'),
//           action: SnackBarAction(
//             label: 'Undo',
//             onPressed: () async {
//               // Restore the story to favorites
//               final restoredStory = updatedStory.copyWith(isFavorite: true);

//               setState(() {
//                 _favoriteStories.add(restoredStory);
//                 // Sort by creation date (newest first)
//                 _favoriteStories
//                     .sort((a, b) => b.createdAt.compareTo(a.createdAt));
//               });

//               // Update in storage
//               final currentStories = await _storageService.loadStories();
//               final storyIndex =
//                   currentStories.indexWhere((s) => s.id == story.id);
//               if (storyIndex != -1) {
//                 currentStories[storyIndex] = restoredStory;
//                 await _storageService.saveStories(currentStories);
//               }
//             },
//           ),
//         ),
//       );
//     }
//   }

//   void _showStoryFullContent(Story story) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final screenHeight = MediaQuery.of(context).size.height;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Container(
//           width: double.infinity,
//           constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFF2A2A2A).withOpacity(0.95),
//                 Color(0xFF1A1A1A).withOpacity(0.95),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF6448FE).withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header with title and buttons
//               Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFF6448FE),
//                       Color(0xFF5FC6FF),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         story.title,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         story.isPlaying ? Icons.stop : Icons.play_arrow,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         _togglePlayback(story);
//                         Navigator.pop(context);
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, color: Colors.white),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Story content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(20),
//                   child: Text(
//                     story.content,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 16,
//                       height: 1.5,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//               ),

//               // Action buttons
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     OutlinedButton.icon(
//                       icon: Icon(Icons.favorite, color: Colors.red),
//                       label: Text(
//                         'Remove from Favorites',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: Colors.white30),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _removeFromFavorites(story);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Favorite Stories',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//           ),
//         ),
//         backgroundColor: const Color(0xFF6448FE),
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF6448FE),
//               Color(0xFF1A1A1A),
//             ],
//             stops: [0.0, 0.3],
//           ),
//         ),
//         child: _favoriteStories.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.favorite_border_rounded,
//                       size: 64,
//                       color: Colors.white.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No favorite stories yet!',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.white.withOpacity(0.7),
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: _favoriteStories.length,
//                 itemBuilder: (context, index) {
//                   final story = _favoriteStories[index];
//                   return Dismissible(
//                     key: Key(story.id),
//                     background: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       alignment: Alignment.centerRight,
//                       padding: const EdgeInsets.only(right: 20),
//                       child: const Icon(
//                         Icons.delete_outline,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                     ),
//                     direction: DismissDirection.endToStart,
//                     confirmDismiss: (direction) async {
//                       return await showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           backgroundColor: const Color(0xFF2A2A2A),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           title: const Text(
//                             'Remove from favorites?',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           content: const Text(
//                             'This story will be removed from your favorites.',
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: const Text(
//                                 'Remove',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     onDismissed: (direction) => _removeFromFavorites(story),
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             const Color(0xFF2A2A2A).withOpacity(0.9),
//                             const Color(0xFF1A1A1A).withOpacity(0.9),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF6448FE).withOpacity(0.2),
//                             blurRadius: 15,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(16),
//                           onTap: () => _showStoryFullContent(story),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         story.title,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 0.3,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         story.content,
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.7),
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             "Tap to read full story",
//                                             style: TextStyle(
//                                               color: const Color(0xFF6448FE),
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           SizedBox(width: 4),
//                                           Icon(
//                                             Icons.arrow_forward,
//                                             size: 12,
//                                             color: const Color(0xFF6448FE),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(
//                                         story.isPlaying
//                                             ? Icons.stop
//                                             : Icons.play_arrow,
//                                         color: const Color(0xFF6448FE),
//                                         size: 28,
//                                       ),
//                                       onPressed: () => _togglePlayback(story),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(
//                                         Icons.favorite,
//                                         color: Colors.red,
//                                         size: 24,
//                                       ),
//                                       onPressed: () =>
//                                           _removeFromFavorites(story),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Stop any playing audio when screen is closed
//     if (_currentlyPlayingStoryId != null) {
//       widget.ttsService.stop();
//     }
//     super.dispose();
//   }
// }

// // Extension method to create a copy of Story with modified properties
// extension StoryCopy on Story {
//   Story copyWith({
//     String? id,
//     String? title,
//     String? content,
//     DateTime? createdAt,
//     bool? isPlaying,
//     bool? isFavorite,
//   }) {
//     return Story(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       content: content ?? this.content,
//       createdAt: createdAt ?? this.createdAt,
//       isPlaying: isPlaying ?? this.isPlaying,
//       isFavorite: isFavorite ?? this.isFavorite,
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Story> favoriteStories;
  final TTSService ttsService;

  const FavoritesScreen({
    Key? key,
    required this.favoriteStories,
    required this.ttsService,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Story> _favoriteStories;
  String? _currentlyPlayingStoryId;
  final StorageService _storageService = StorageService.instance;

  @override
  void initState() {
    super.initState();
    _favoriteStories = List.from(widget.favoriteStories);

    // Listen for when TTS playback completes
    widget.ttsService.positionStream?.listen((position) {
      // Update UI when playback completes
      if (!widget.ttsService.isPlaying && _currentlyPlayingStoryId != null) {
        setState(() {
          final storyIndex = _favoriteStories
              .indexWhere((s) => s.id == _currentlyPlayingStoryId);
          if (storyIndex != -1) {
            _favoriteStories[storyIndex] =
                _favoriteStories[storyIndex].copyWith(isPlaying: false);
          }
          _currentlyPlayingStoryId = null;
        });
      }
    });
  }

  Future<void> _togglePlayback(Story story) async {
    try {
      if (_currentlyPlayingStoryId == story.id) {
        // Stop current playback
        await widget.ttsService.stop();
        setState(() {
          _currentlyPlayingStoryId = null;
          final storyIndex = _favoriteStories.indexOf(story);
          _favoriteStories[storyIndex] = story.copyWith(isPlaying: false);
        });
      } else {
        // Stop any current playback
        if (_currentlyPlayingStoryId != null) {
          final currentStoryIndex = _favoriteStories.indexWhere(
            (s) => s.id == _currentlyPlayingStoryId,
          );
          if (currentStoryIndex != -1) {
            await widget.ttsService.stop();
            setState(() {
              _favoriteStories[currentStoryIndex] =
                  _favoriteStories[currentStoryIndex]
                      .copyWith(isPlaying: false);
            });
          }
        }

        // Start new playback
        setState(() {
          _currentlyPlayingStoryId = story.id;
          final storyIndex = _favoriteStories.indexOf(story);
          _favoriteStories[storyIndex] = story.copyWith(isPlaying: true);
        });

        // Use play method from ttsService - make sure content field is used correctly
        await widget.ttsService.play(story.content);
      }
    } catch (e) {
      setState(() {
        _currentlyPlayingStoryId = null;
        final storyIndex = _favoriteStories.indexOf(story);
        if (storyIndex != -1) {
          _favoriteStories[storyIndex] =
              _favoriteStories[storyIndex].copyWith(isPlaying: false);
        }
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

  Future<void> _removeFromFavorites(Story story) async {
    // First stop playback if this story is currently playing
    if (_currentlyPlayingStoryId == story.id) {
      await widget.ttsService.stop();
      _currentlyPlayingStoryId = null;
    }

    // Create a modified version of the story with isFavorite = false
    final updatedStory = story.copyWith(isFavorite: false, isPlaying: false);

    // Remove from local list
    setState(() {
      _favoriteStories.removeWhere((s) => s.id == story.id);
    });

    // Update in storage by loading all stories, updating this one, and saving back
    final allStories = await _storageService.loadStories();
    final storyIndex = allStories.indexWhere((s) => s.id == story.id);
    if (storyIndex != -1) {
      allStories[storyIndex] = updatedStory;
      await _storageService.saveStories(allStories);
    }

    // Show confirmation
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Restore the story to favorites
              final restoredStory = updatedStory.copyWith(isFavorite: true);

              setState(() {
                _favoriteStories.add(restoredStory);
                // Sort by creation date (newest first)
                _favoriteStories
                    .sort((a, b) => b.createdAt.compareTo(a.createdAt));
              });

              // Update in storage
              final currentStories = await _storageService.loadStories();
              final storyIndex =
                  currentStories.indexWhere((s) => s.id == story.id);
              if (storyIndex != -1) {
                currentStories[storyIndex] = restoredStory;
                await _storageService.saveStories(currentStories);
              }
            },
          ),
        ),
      );
    }
  }

  void _showStoryFullContent(Story story) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2A2A).withOpacity(0.95),
                Color(0xFF1A1A1A).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6448FE).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6448FE),
                      Color(0xFF5FC6FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                        story.isPlaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _togglePlayback(story);
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Story content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    story.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      label: const Text(
                        'Remove from Favorites',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _removeFromFavorites(story);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Stories',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF6448FE),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6448FE),
              Color(0xFF1A1A1A),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: _favoriteStories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorite stories yet!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _favoriteStories.length,
                itemBuilder: (context, index) {
                  final story = _favoriteStories[index];
                  return Dismissible(
                    key: Key(story.id),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
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
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF2A2A2A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Remove from favorites?',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'This story will be removed from your favorites.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) => _removeFromFavorites(story),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2A2A2A).withOpacity(0.9),
                            const Color(0xFF1A1A1A).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6448FE).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showStoryFullContent(story),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        story.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        story.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: const [
                                          Text(
                                            "Tap to read full story",
                                            style: TextStyle(
                                              color: Color(0xFF6448FE),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 12,
                                            color: Color(0xFF6448FE),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        story.isPlaying
                                            ? Icons.stop
                                            : Icons.play_arrow,
                                        color: const Color(0xFF6448FE),
                                        size: 28,
                                      ),
                                      onPressed: () => _togglePlayback(story),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          _removeFromFavorites(story),
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
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop any playing audio when screen is closed
    if (_currentlyPlayingStoryId != null) {
      widget.ttsService.stop();
    }
    super.dispose();
  }
}
