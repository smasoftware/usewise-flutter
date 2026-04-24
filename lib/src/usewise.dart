import 'dart:async';
import 'package:usewise_flutter/src/config.dart';
import 'package:usewise_flutter/src/models/event.dart';
import 'package:usewise_flutter/src/models/identify.dart';
import 'package:usewise_flutter/src/models/process.dart';
import 'package:usewise_flutter/src/models/api_response.dart';
import 'package:usewise_flutter/src/transport/http_client.dart';
import 'package:usewise_flutter/src/transport/api_client.dart';
import 'package:usewise_flutter/src/queue/event_queue.dart';
import 'package:usewise_flutter/src/persistence/storage.dart';
import 'package:usewise_flutter/src/persistence/shared_prefs_storage.dart';
import 'package:usewise_flutter/src/utils/id_generator.dart';
import 'package:usewise_flutter/src/utils/screen_info.dart';
import 'package:usewise_flutter/src/utils/device_context.dart';

const _keyAnonymousId = 'usewise_anonymous_id';
const _keyOptedOut = 'usewise_opted_out';

class Usewise {
  static Usewise? _instance;

  late final ApiClient _apiClient;
  late final EventQueue _eventQueue;
  late final StorageAdapter _storage;
  late String _anonymousId;
  late DeviceContext _deviceContext;
  String? _userId;
  bool _optedOut = false;

  Usewise._();

  static Usewise get instance {
    if (_instance == null) {
      throw const UsewiseNotInitializedException();
    }
    return _instance!;
  }

  static Future<void> init(UsewiseConfig config, {StorageAdapter? storage}) async {
    final usewise = Usewise._();
    // Persistence
    usewise._storage = storage ?? SharedPrefsStorage();
    await usewise._storage.init();

    // Load or generate anonymous ID
    final storedId = await usewise._storage.getString(_keyAnonymousId);
    if (storedId != null) {
      usewise._anonymousId = storedId;
    } else {
      usewise._anonymousId = IdGenerator.uuid();
      await usewise._storage.setString(_keyAnonymousId, usewise._anonymousId);
    }

    // Load opt-out state
    usewise._optedOut = await usewise._storage.getBool(_keyOptedOut) ?? false;

    // Device context
    usewise._deviceContext = await DeviceContext.capture();

    // Transport
    final httpClient = UsewiseHttpClient(
      baseUrl: config.baseUrl,
      apiKey: config.apiKey,
      timeout: config.httpTimeout,
      maxRetries: config.maxRetries,
      enableLogging: config.enableLogging,
    );
    usewise._apiClient = ApiClient(httpClient);

    // Queue
    usewise._eventQueue = EventQueue(
      apiClient: usewise._apiClient,
      flushAt: config.flushAt,
      maxQueueSize: config.maxQueueSize,
      flushInterval: Duration(milliseconds: config.flushIntervalMs),
      enableLogging: config.enableLogging,
    );
    usewise._eventQueue.start();

    _instance = usewise;
  }

  String get anonymousId => _anonymousId;
  String? get userId => _userId;
  bool get isOptedOut => _optedOut;

  void track(
    String event, {
    Map<String, dynamic>? properties,
    ElementData? element,
    PageData? page,
  }) {
    if (_optedOut) return;

    final trackEvent = TrackEvent(
      event: event,
      anonymousId: _anonymousId,
      userId: _userId,
      eventUuid: IdGenerator.uuid(),
      timestamp: DateTime.now().toUtc().toIso8601String(),
      properties: properties,
      element: element,
      page: page,
      screen: ScreenInfo.capture(),
      context: DeviceContextData(
        deviceOs: _deviceContext.deviceOS,
        deviceModel: _deviceContext.deviceModel,
        appVersion: _deviceContext.appVersion,
        isVpn: _deviceContext.isVpn,
        isJailbroken: _deviceContext.isJailbroken,
      ),
    );

    _eventQueue.add(trackEvent);
  }

  Future<void> identify(String userId, {Map<String, dynamic>? traits}) async {
    if (_optedOut) return;

    // Flush pending events with old identity
    await flush();

    _userId = userId;

    await _apiClient.identify(IdentifyPayload(
      anonymousId: _anonymousId,
      userId: userId,
      traits: traits,
    ));
  }

  Future<String> startProcess(String name, {Map<String, dynamic>? properties}) async {
    if (_optedOut) return '';

    final response = await _apiClient.startProcess(ProcessStartPayload(
      processName: name,
      anonymousId: _anonymousId,
      userId: _userId,
      properties: properties,
    ));

    return response.processId;
  }

  Future<ProcessStepResponse> processStep(
    String processId,
    String stepName, {
    Map<String, dynamic>? properties,
  }) async {
    if (_optedOut) {
      return const ProcessStepResponse(
        stepId: '',
        stepName: '',
        stepOrder: 0,
        durationMs: 0,
      );
    }

    return _apiClient.processStep(ProcessStepPayload(
      processId: processId,
      stepName: stepName,
      properties: properties,
    ));
  }

  Future<ProcessCompleteResponse> completeProcess(String processId) async {
    if (_optedOut) {
      return const ProcessCompleteResponse(totalSteps: 0, totalDurationMs: 0);
    }

    return _apiClient.completeProcess(ProcessCompletePayload(
      processId: processId,
    ));
  }

  Future<ProcessCompleteResponse> failProcess(String processId, {String? reason}) async {
    if (_optedOut) {
      return const ProcessCompleteResponse(totalSteps: 0, totalDurationMs: 0);
    }

    return _apiClient.failProcess(ProcessFailPayload(
      processId: processId,
      reason: reason,
    ));
  }

  Future<void> flush() async {
    if (_optedOut) return;
    await _eventQueue.flush();
  }

  Future<void> reset() async {
    _userId = null;
    _anonymousId = IdGenerator.uuid();
    await _storage.setString(_keyAnonymousId, _anonymousId);
    _eventQueue.clear();
  }

  Future<void> optOut() async {
    _optedOut = true;
    await _storage.setBool(_keyOptedOut, true);
    _eventQueue.clear();
  }

  Future<void> optIn() async {
    _optedOut = false;
    await _storage.setBool(_keyOptedOut, false);
  }

  Future<void> shutdown() async {
    await flush();
    _eventQueue.dispose();
    _apiClient.close();
    _instance = null;
  }
}
