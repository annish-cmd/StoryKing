/*
 * STORY SERVICE
 * ------------
 * Handles AI-powered story generation using the OpenRouter API.
 * 
 * Main functions:
 * - Connects to AI model for story generation
 * - Processes user prompts into complete stories
 * - Formats and cleans up generated content
 * - Works with both English and Nepali languages
 * 
 * Technical details:
 * - Uses deepseek-chat model for generation
 * - Handles API authentication with API key
 * - Creates Story objects with unique IDs
 * - Properly formats responses with titles and content
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';
import 'package:uuid/uuid.dart';

class StoryService {
  final String apiKey;
  final String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final _uuid = const Uuid();
  final _client = http.Client();

  StoryService({required this.apiKey});

  /// Generates a story for a specific user
  Future<Story> generateStory(String prompt, {required String userId}) async {
    try {
      // Detect if the prompt is in Nepali
      bool isNepali = RegExp(r'[\u0900-\u097F]').hasMatch(prompt);

      // Updated system prompt to avoid asterisks
      final systemPrompt = isNepali
          ? 'कथाकार: ७५-१०० शब्दको छोटो कथा लेख्नुहोस्। शीर्षक "शीर्षक:" बाट सुरु गर्नुहोस्।'
          : 'Write a very short story (75-100 words) with a clear plot. Start with "Title:" (do not use any asterisks or special formatting)';

      final response = await _client
          .post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'HTTP-Referer': 'storyking.app',
          'X-Title': 'StoryKing',
        },
        body: utf8.encode(jsonEncode({
          'model': 'deepseek/deepseek-chat:free',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt}
          ],

          // Increase Tokens for story generation Deepseek:
          'temperature': 0.7,
          'max_tokens': 300,
          'top_p': 0.7,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
          'stream': false,
        })),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices']?[0]?['message']?['content'] != null) {
          final storyContent = data['choices'][0]['message']['content'];
          final titleMatch = RegExp(r'^Title:|^शीर्षक:', caseSensitive: false)
              .firstMatch(storyContent);

          String title;
          String content;

          if (titleMatch != null) {
            final splitIndex = storyContent.indexOf('\n');
            if (splitIndex > 0) {
              title = storyContent.substring(titleMatch.end, splitIndex).trim();
              content = storyContent.substring(splitIndex + 1).trim();
            } else {
              // Handle case where there's no newline
              title = _extractTitle(prompt);
              content = storyContent.trim();
            }
          } else {
            title = _extractTitle(prompt);
            content = storyContent.trim();
          }

          // Clean up title and content
          title = _cleanupText(title);
          content = _cleanupText(content);

          // Create story with proper userId association
          return Story(
            id: _uuid.v4(),
            title: title.isEmpty ? _extractTitle(prompt) : title,
            content: content,
            userId: userId,
            createdAt: DateTime.now(),
            isFavorite: false,
            isPlaying: false,
          );
        }
        throw Exception('Invalid response format from API');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception(
            'Failed to generate story: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating story: $e');
    }
  }

  /// Extracts a title from the prompt when no title is provided by the AI
  String _extractTitle(String prompt) {
    final words = prompt.split(' ');
    return words.length < 3 ? prompt : '${words.take(3).join(' ')}...';
  }

  /// Cleans up text by removing special characters and normalizing whitespace
  String _cleanupText(String text) {
    return text
        .replaceAll(RegExp(r'\*+'), '') // Remove asterisks
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(''', "'")
        .replaceAll(''', "'")
        .replaceAll('"', '"')
        .replaceAll('"', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('…', '...')
        .trim();
  }

  /// Properly close client when service is no longer needed
  void dispose() {
    _client.close();
  }
}
