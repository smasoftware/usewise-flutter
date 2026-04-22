import 'dart:async';
import 'package:usewise_flutter/src/models/event.dart';
import 'package:usewise_flutter/src/transport/api_client.dart';

class EventQueue {
  final ApiClient _apiClient;
  final int flushAt;
  final int maxQueueSize;
  final Duration flushInterval;
  final bool enableLogging;

  final List<TrackEvent> _queue = [];
  Timer? _flushTimer;
  bool _isFlushing = false;
  Completer<void>? _flushCompleter;

  EventQueue({
    required ApiClient apiClient,
    this.flushAt = 20,
    this.maxQueueSize = 1000,
    this.flushInterval = const Duration(seconds: 30),
    this.enableLogging = false,
  }) : _apiClient = apiClient;

  void start() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
  }

  void add(TrackEvent event) {
    _queue.add(event);

    // Drop oldest if over capacity
    while (_queue.length > maxQueueSize) {
      _queue.removeAt(0);
    }

    // Threshold flush
    if (_queue.length >= flushAt) {
      flush();
    }
  }

  Future<void> flush() async {
    // Coalesce concurrent flush calls
    if (_isFlushing) {
      return _flushCompleter?.future ?? Future<void>.value();
    }
    if (_queue.isEmpty) return;

    _isFlushing = true;
    _flushCompleter = Completer<void>();

    try {
      while (_queue.isNotEmpty) {
        // Take up to 100 (server batch limit)
        final batchSize = _queue.length < 100 ? _queue.length : 100;
        final batch = _queue.sublist(0, batchSize);

        try {
          await _apiClient.batch(batch);
          _queue.removeRange(0, batchSize);
        } catch (e) {
          // On failure, leave events in queue for next cycle
          if (enableLogging) {
            // ignore: avoid_print
            print('[Usewise] Flush failed: $e');
          }
          break;
        }
      }
    } finally {
      _isFlushing = false;
      _flushCompleter?.complete();
      _flushCompleter = null;
    }
  }

  void clear() {
    _queue.clear();
  }

  int get length => _queue.length;

  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}
