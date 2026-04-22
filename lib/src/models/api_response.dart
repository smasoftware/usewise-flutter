class TrackResponse {
  final String? eventId;
  final bool deduplicated;

  const TrackResponse({this.eventId, this.deduplicated = false});

  factory TrackResponse.fromJson(Map<String, dynamic> json) {
    return TrackResponse(
      eventId: json['event_id'] as String?,
      deduplicated: json['deduplicated'] as bool? ?? false,
    );
  }
}

class BatchResponse {
  final int accepted;
  final int rejected;

  const BatchResponse({this.accepted = 0, this.rejected = 0});

  factory BatchResponse.fromJson(Map<String, dynamic> json) {
    return BatchResponse(
      accepted: json['accepted'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
    );
  }
}

class ProcessStartResponse {
  final String processId;
  final String processName;
  final String startedAt;

  const ProcessStartResponse({
    required this.processId,
    required this.processName,
    required this.startedAt,
  });

  factory ProcessStartResponse.fromJson(Map<String, dynamic> json) {
    return ProcessStartResponse(
      processId: json['process_id'] as String,
      processName: json['process_name'] as String,
      startedAt: json['started_at'] as String,
    );
  }
}

class ProcessStepResponse {
  final String stepId;
  final String stepName;
  final int stepOrder;
  final int durationMs;

  const ProcessStepResponse({
    required this.stepId,
    required this.stepName,
    required this.stepOrder,
    required this.durationMs,
  });

  factory ProcessStepResponse.fromJson(Map<String, dynamic> json) {
    return ProcessStepResponse(
      stepId: json['step_id'] as String,
      stepName: json['step_name'] as String,
      stepOrder: json['step_order'] as int,
      durationMs: json['duration_ms'] as int,
    );
  }
}

class ProcessCompleteResponse {
  final int totalSteps;
  final int totalDurationMs;

  const ProcessCompleteResponse({
    required this.totalSteps,
    required this.totalDurationMs,
  });

  factory ProcessCompleteResponse.fromJson(Map<String, dynamic> json) {
    return ProcessCompleteResponse(
      totalSteps: json['total_steps'] as int,
      totalDurationMs: json['total_duration_ms'] as int,
    );
  }
}
