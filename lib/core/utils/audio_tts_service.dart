import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioTtsService {
  static final AudioTtsService _instance = AudioTtsService._internal();
  factory AudioTtsService() => _instance;
  AudioTtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;

  Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setSpeechRate(0.48); // Natural, clear pedagogical pace
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS initialization notice: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      if (!_isInitialized) {
        await _initTts();
      }
      if (_flutterTts != null) {
        // Strip IPA brackets if present for clean synthesis
        final cleanText = text
            .replaceAll(RegExp(r'/[^/]+?/'), '')
            .replaceAll(RegExp(r'\[.*?\]'), '')
            .trim();
        if (cleanText.isNotEmpty) {
          await _flutterTts!.stop();
          await _flutterTts!.speak(cleanText);
        }
      }
    } catch (e) {
      debugPrint("TTS speak notice: $e");
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (_) {}
  }
}

