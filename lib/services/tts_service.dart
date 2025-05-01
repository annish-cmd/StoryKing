/*
 * TEXT-TO-SPEECH SERVICE
 * --------------------
 * Converts story text to audio using the ElevenLabs API.
 * 
 * Main functions:
 * - Text-to-speech conversion
 * - Audio playback management
 * - Language detection (English/Nepali)
 * - Playback controls (play/stop)
 * 
 * Technical details:
 * - Integrates with ElevenLabs API
 * - Uses just_audio for playback
 * - Optimizes voice settings based on language
 * - Provides streams for playback position/duration
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class TTSService {
  final String apiKey;
  final String baseUrl = 'https://api.elevenlabs.io/v1';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  StreamController<Duration>? _positionController;
  StreamController<Duration>? _durationController;

  static const String englishVoiceId = '21m00Tcm4TlvDq8ikWAM';
  static const String multilingualVoiceId = 'pNInz6obpgDQGcFmaJgB';

  TTSService({required this.apiKey}) {
    _initStreams();
  }

  bool get isPlaying => _isPlaying;
  Stream<Duration>? get positionStream => _positionController?.stream;
  Stream<Duration>? get durationStream => _durationController?.stream;

  void _initStreams() {
    _positionController = StreamController<Duration>.broadcast();
    _durationController = StreamController<Duration>.broadcast();

    _audioPlayer.positionStream.listen((position) {
      _positionController?.add(position);
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _durationController?.add(duration);
      }
    });
  }

  bool _isNepaliText(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }

  String _improveNepaliText(String text) {
    // Add spaces around punctuation
    for (var punctuation in [',', '!', '?']) {
      text = text.replaceAll(punctuation, ' $punctuation ');
    }

    // Handle special Nepali punctuation
    text = text.replaceAll('।', ' । ');

    // Normalize multiple spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Add pauses after sentence endings
    text = text.replaceAll('।', '। <break time="500ms"/>');

    // Improve pronunciation of challenging consonants
    text = text.replaceAll('छ', 'छ्छ');
    text = text.replaceAll('झ', 'झ्झ');
    text = text.replaceAll('ठ', 'ठ्ठ');
    text = text.replaceAll('ढ', 'ढ्ढ');

    // Add spaces for common postpositions
    text = text.replaceAll('को', ' को');
    text = text.replaceAll('मा', ' मा');
    text = text.replaceAll('ले', ' ले');
    text = text.replaceAll('लाई', ' लाई');
    text = text.replaceAll('बाट', ' बाट');
    text = text.replaceAll('देखि', ' देखि');
    text = text.replaceAll('सम्म', ' सम्म');

    // Add subtle pauses between sentences
    text = text.replaceAll('। ', '। <break time="300ms"/> ');

    return text.trim();
  }

  Future<void> play(String text) async {
    try {
      final isNepali = _isNepaliText(text);
      final voiceId = isNepali ? multilingualVoiceId : englishVoiceId;

      String processedText = isNepali ? _improveNepaliText(text) : text;

      final voiceSettings = isNepali
          ? {
              'stability': 0.82,
              'similarity_boost': 0.85,
              'style': 0.4,
              'use_speaker_boost': true,
              'speaking_rate': 0.80
            }
          : {
              'stability': 0.35,
              'similarity_boost': 0.65,
              'style': 0.5,
              'use_speaker_boost': true,
              'speaking_rate': 1.2
            };

      final client = http.Client();
      try {
        final response = await client
            .post(
              Uri.parse('$baseUrl/text-to-speech/$voiceId/stream'),
              headers: {
                'accept': 'audio/mpeg',
                'xi-api-key': apiKey,
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'text': processedText,
                'model_id': isNepali
                    ? 'eleven_multilingual_v2'
                    : 'eleven_monolingual_v1',
                'voice_settings': voiceSettings
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final audioUrl =
              Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg').toString();

          await _audioPlayer.setUrl(audioUrl);
          await _audioPlayer.setSpeed(isNepali ? 0.85 : 1.15);
          await _audioPlayer.play();
          _isPlaying = true;

          _audioPlayer.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
            }
          });
        } else {
          print('ElevenLabs API Error: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to generate speech: ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('TTS Error: $e');
      throw Exception('Error generating speech: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  void dispose() {
    _audioPlayer.dispose();
    _positionController?.close();
    _durationController?.close();
  }
}
