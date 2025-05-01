// firebase_storage_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/story.dart';
import 'storage_repository.dart';

/// Firebase implementation of StoryRepository using Firestore
class FirebaseStorageRepository implements StoryRepository {
  final FirebaseFirestore _firestore;
  static const String _storiesCollection = 'stories';

  /// Constructor with Firestore instance
  FirebaseStorageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get reference to stories collection
  CollectionReference<Map<String, dynamic>> get _storiesRef =>
      _firestore.collection(_storiesCollection);

  @override
  Future<void> saveStories(List<Story> stories) async {
    if (stories.isEmpty) return;

    // Use a batch to perform multiple writes atomically
    final batch = _firestore.batch();

    for (final story in stories) {
      final docRef = _storiesRef.doc(story.id);
      batch.set(docRef, story.toJson());
    }

    await batch.commit();
  }

  @override
  Future<List<Story>?> loadStoriesForUser(String userId) async {
    try {
      final snapshot = await _storiesRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Story.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error loading stories from Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> addStory(Story story) async {
    await _storiesRef.doc(story.id).set(story.toJson());
  }

  @override
  Future<void> updateStory(Story story) async {
    await _storiesRef.doc(story.id).update(story.toJson());
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await _storiesRef.doc(storyId).delete();
  }

  @override
  Future<void> clearUserStories(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _storiesRef.where('userId', isEqualTo: userId).get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
