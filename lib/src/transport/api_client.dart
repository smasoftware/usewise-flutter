import 'dart:convert';
import 'package:usewise_flutter/src/models/api_response.dart';
import 'package:usewise_flutter/src/models/event.dart';
import 'package:usewise_flutter/src/models/identify.dart';
import 'package:usewise_flutter/src/models/process.dart';
import 'package:usewise_flutter/src/transport/http_client.dart';

class ApiClient {
  final UsewiseHttpClient _http;

  ApiClient(this._http);

  Future<TrackResponse> track(TrackEvent event) async {
    final response = await _http.post('/v1/track', event.toJson());
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TrackResponse.fromJson(data);
  }

  Future<BatchResponse> batch(List<TrackEvent> events) async {
    final response = await _http.post('/v1/batch', {
      'batch': events.map((e) => e.toJson()).toList(),
    });
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchResponse.fromJson(data);
  }

  Future<void> identify(IdentifyPayload payload) async {
    await _http.post('/v1/identify', payload.toJson());
  }

  Future<ProcessStartResponse> startProcess(ProcessStartPayload payload) async {
    final response = await _http.post('/v1/process/start', payload.toJson());
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ProcessStartResponse.fromJson(data);
  }

  Future<ProcessStepResponse> processStep(ProcessStepPayload payload) async {
    final response = await _http.post('/v1/process/step', payload.toJson());
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ProcessStepResponse.fromJson(data);
  }

  Future<ProcessCompleteResponse> completeProcess(ProcessCompletePayload payload) async {
    final response = await _http.post('/v1/process/complete', payload.toJson());
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ProcessCompleteResponse.fromJson(data);
  }

  void close() => _http.close();
}
