class UsewiseConfig {
  final String apiKey;
  final String baseUrl;
  final int flushIntervalMs;
  final int flushAt;
  final int maxQueueSize;
  final int maxRetries;
  final bool enableLogging;
  final Duration httpTimeout;

  const UsewiseConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.usewise.io',
    this.flushIntervalMs = 30000,
    this.flushAt = 20,
    this.maxQueueSize = 1000,
    this.maxRetries = 3,
    this.enableLogging = false,
    this.httpTimeout = const Duration(seconds: 10),
  });
}
