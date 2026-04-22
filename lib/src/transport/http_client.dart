import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class UsewiseException implements Exception {
  final String message;
  const UsewiseException(this.message);

  @override
  String toString() => 'UsewiseException: $message';
}

class UsewiseApiException extends UsewiseException {
  final int statusCode;
  final String? errorCode;

  const UsewiseApiException(super.message, {required this.statusCode, this.errorCode});

  @override
  String toString() => 'UsewiseApiException($statusCode): $message';
}

class UsewiseNetworkException extends UsewiseException {
  final Object? originalError;

  const UsewiseNetworkException(super.message, {this.originalError});
}

class UsewiseNotInitializedException extends UsewiseException {
  const UsewiseNotInitializedException() : super('Usewise has not been initialized. Call Usewise.init() first.');
}

class UsewiseHttpClient {
  final String baseUrl;
  final String apiKey;
  final Duration timeout;
  final int maxRetries;
  final bool enableLogging;
  final http.Client _httpClient;
  final Random _random = Random();

  UsewiseHttpClient({
    required this.baseUrl,
    required this.apiKey,
    required this.timeout,
    required this.maxRetries,
    this.enableLogging = false,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Key': apiKey,
    };
    final encodedBody = jsonEncode(body);

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .post(uri, headers: headers, body: encodedBody)
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // 4xx — client error, don't retry
        if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 429) {
          final data = _tryParseJson(response.body);
          throw UsewiseApiException(
            data?['error']?['message'] as String? ?? response.reasonPhrase ?? 'Client error',
            statusCode: response.statusCode,
            errorCode: data?['error']?['code'] as String?,
          );
        }

        // 429 or 5xx — retry
        if (attempt < maxRetries) {
          final delay = _backoffDelay(attempt, response);
          if (enableLogging) {
            // ignore: avoid_print
            print('[Usewise] Retry $attempt after ${delay.inMilliseconds}ms (status: ${response.statusCode})');
          }
          await Future<void>.delayed(delay);
          continue;
        }

        throw UsewiseApiException(
          'Server error after $maxRetries retries',
          statusCode: response.statusCode,
        );
      } on UsewiseApiException {
        rethrow;
      } on TimeoutException {
        if (attempt >= maxRetries) {
          throw const UsewiseNetworkException('Request timed out after all retries');
        }
        await Future<void>.delayed(_backoffDelay(attempt));
      } catch (e) {
        if (e is UsewiseException) rethrow;
        if (attempt >= maxRetries) {
          throw UsewiseNetworkException('Network error after all retries', originalError: e);
        }
        await Future<void>.delayed(_backoffDelay(attempt));
      }
    }

    throw const UsewiseNetworkException('Request failed after all retries');
  }

  Duration _backoffDelay(int attempt, [http.Response? response]) {
    // Check Retry-After header for 429
    if (response?.statusCode == 429) {
      final retryAfter = response?.headers['retry-after'];
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) return Duration(seconds: seconds);
      }
    }

    // Exponential backoff: min(1s * 2^attempt + jitter, 30s)
    final baseMs = 1000 * pow(2, attempt).toInt();
    final jitterMs = _random.nextInt(500);
    final delayMs = min(baseMs + jitterMs, 30000);
    return Duration(milliseconds: delayMs);
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void close() {
    _httpClient.close();
  }
}
