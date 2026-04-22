class ProcessStartPayload {
  final String processName;
  final String? anonymousId;
  final String? userId;
  final Map<String, dynamic>? properties;

  const ProcessStartPayload({
    required this.processName,
    this.anonymousId,
    this.userId,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'process_name': processName,
    };
    if (anonymousId != null) json['anonymous_id'] = anonymousId;
    if (userId != null) json['user_id'] = userId;
    if (properties != null) json['properties'] = properties;
    return json;
  }
}

class ProcessStepPayload {
  final String processId;
  final String stepName;
  final Map<String, dynamic>? properties;

  const ProcessStepPayload({
    required this.processId,
    required this.stepName,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'process_id': processId,
      'step_name': stepName,
    };
    if (properties != null) json['properties'] = properties;
    return json;
  }
}

class ProcessCompletePayload {
  final String processId;

  const ProcessCompletePayload({required this.processId});

  Map<String, dynamic> toJson() => {'process_id': processId};
}
