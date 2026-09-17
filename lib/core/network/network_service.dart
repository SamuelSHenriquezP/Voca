import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkStatus {
  final bool isOnline;
  final int latencyMs;
  final String statusMessage;

  const NetworkStatus({
    required this.isOnline,
    required this.latencyMs,
    required this.statusMessage,
  });
}

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool _isOnline = true;
  int _lastLatencyMs = 28;
  bool get isOnline => _isOnline;
  int get lastLatencyMs => _lastLatencyMs;

  /// Performs an active DNS/Socket ping to test real live internet access
  Future<NetworkStatus> checkInternetAccess() async {
    final stopwatch = Stopwatch()..start();
    try {
      final results = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));

      stopwatch.stop();
      if (results.isNotEmpty && results[0].rawAddress.isNotEmpty) {
        _isOnline = true;
        _lastLatencyMs = stopwatch.elapsedMilliseconds;
        return NetworkStatus(
          isOnline: true,
          latencyMs: _lastLatencyMs,
          statusMessage: 'Conectado a Internet (${_lastLatencyMs}ms)',
        );
      }
    } catch (e) {
      debugPrint('Internet lookup error: $e');
    }

    // Secondary fallback check via Cloudflare DNS IP directly (avoids DNS issues)
    try {
      final socket = await Socket.connect('1.1.1.1', 53, timeout: const Duration(seconds: 3));
      socket.destroy();
      stopwatch.stop();
      _isOnline = true;
      _lastLatencyMs = stopwatch.elapsedMilliseconds;
      return NetworkStatus(
        isOnline: true,
        latencyMs: _lastLatencyMs,
        statusMessage: 'Conectado a Internet (${_lastLatencyMs}ms)',
      );
    } catch (_) {
      stopwatch.stop();
      _isOnline = false;
      return const NetworkStatus(
        isOnline: false,
        latencyMs: -1,
        statusMessage: 'Sin conexión a Internet (Modo Local Offline activo)',
      );
    }
  }

  /// Sends a prompt to Google Gemini API (gemini-1.5-flash) over HTTPS
  Future<String?> callGemini({
    required String apiKey,
    required String prompt,
    String? systemInstruction,
  }) async {
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        if (systemInstruction != null)
          'systemInstruction': {
            'parts': [
              {'text': systemInstruction}
            ]
          },
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 200,
        }
      };

      request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final candidates = json['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String?;
          }
        }
      } else {
        debugPrint('Gemini API HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gemini API call notice: $e');
    }
    return null;
  }

  /// Sends a prompt to OpenAI API (gpt-4o-mini) over HTTPS
  Future<String?> callOpenAi({
    required String apiKey,
    required String prompt,
    String? systemInstruction,
  }) async {
    try {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final body = {
        'model': 'gpt-4o-mini',
        'messages': [
          if (systemInstruction != null)
            {'role': 'system', 'content': systemInstruction},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      };

      request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = json['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content'] as String?;
        }
      }
    } catch (e) {
      debugPrint('OpenAI API call notice: $e');
    }
    return null;
  }
}

