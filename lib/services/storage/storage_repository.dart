// storage_repository.dart
import '../../models/story.dart';

/// Abstract repository for story storage operations
abstract class StoryRepository {
  /// Saves a list of stories
  Future<void> saveStories(List<Story> stories);

  /// Loads stories for a specific user
  Future<List<Story>?> loadStoriesForUser(String userId);

  /// Adds a single story
  Future<void> addStory(Story story);

  /// Updates an existing story
  Future<void> updateStory(Story story);

  /// Deletes a story by ID
  Future<void> deleteStory(String storyId);

  /// Clear all stories for a specific user
  Future<void> clearUserStories(String userId);
}
