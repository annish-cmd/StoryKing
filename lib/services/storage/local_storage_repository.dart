// local_storage_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/story.dart';
import 'storage_repository.dart';

/// Local implementation of StoryRepository using SharedPreferences
class LocalStorageRepository implements StoryRepository {
  static const String _storiesKey = 'user_stories';
  final SharedPreferences _prefs;

  /// Private constructor with required SharedPreferences
  LocalStorageRepository._({required SharedPreferences prefs}) : _prefs = prefs;

  /// Factory method to initialize the repository
  static Future<LocalStorageRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageRepository._(prefs: prefs);
  }

  @override
  Future<void> saveStories(List<Story> stories) async {
    if (stories.isEmpty) return;

    final userId = stories.first.userId;
    final allStoriesMap = _getAllStoriesMap();

    // Update user's stories
    final userStories = stories.map((story) => story.toJson()).toList();
    allStoriesMap[userId] = userStories;

    // Save back to shared preferences
    await _prefs.setString(_storiesKey, jsonEncode(allStoriesMap));
  }

  @override
  Future<List<Story>?> loadStoriesForUser(String userId) async {
    try {
      final allStoriesMap = _getAllStoriesMap();

      if (!allStoriesMap.containsKey(userId)) {
        return [];
      }

      final userStoriesJson = allStoriesMap[userId] as List<dynamic>;
      return userStoriesJson
          .map((storyJson) => Story.fromJson(storyJson))
          .toList();
    } catch (e) {
      print('Error loading stories: $e');
      return [];
    }
  }

  @override
  Future<void> addStory(Story story) async {
    final allStoriesMap = _getAllStoriesMap();
    final userId = story.userId;

    // Get existing stories for user or create empty list
    final userStories = allStoriesMap[userId] != null
        ? List<Map<String, dynamic>>.from(allStoriesMap[userId])
        : <Map<String, dynamic>>[];

    // Add new story
    userStories.add(story.toJson());
    allStoriesMap[userId] = userStories;

    // Save back to shared preferences
    await _prefs.setString(_storiesKey, jsonEncode(allStoriesMap));
  }

  @override
  Future<void> updateStory(Story story) async {
    final allStoriesMap = _getAllStoriesMap();
    final userId = story.userId;

    if (!allStoriesMap.containsKey(userId)) {
      return;
    }

    final userStories = List<Map<String, dynamic>>.from(allStoriesMap[userId]);

    // Find and update the story
    final storyIndex = userStories.indexWhere((s) => s['id'] == story.id);
    if (storyIndex != -1) {
      userStories[storyIndex] = story.toJson();
      allStoriesMap[userId] = userStories;
      await _prefs.setString(_storiesKey, jsonEncode(allStoriesMap));
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    final allStoriesMap = _getAllStoriesMap();

    // Find which user has this story
    for (final userId in allStoriesMap.keys) {
      final userStories =
          List<Map<String, dynamic>>.from(allStoriesMap[userId]);
      final storyIndex = userStories.indexWhere((s) => s['id'] == storyId);

      if (storyIndex != -1) {
        userStories.removeAt(storyIndex);
        allStoriesMap[userId] = userStories;
        await _prefs.setString(_storiesKey, jsonEncode(allStoriesMap));
        break;
      }
    }
  }

  @override
  Future<void> clearUserStories(String userId) async {
    final allStoriesMap = _getAllStoriesMap();

    if (allStoriesMap.containsKey(userId)) {
      allStoriesMap.remove(userId);
      await _prefs.setString(_storiesKey, jsonEncode(allStoriesMap));
    }
  }

  /// Helper method to get all stories map from SharedPreferences
  Map<String, dynamic> _getAllStoriesMap() {
    final jsonString = _prefs.getString(_storiesKey);
    if (jsonString == null) {
      return {};
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
