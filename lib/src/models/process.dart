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

class ProcessSubStartPayload {
  final String parentProcessId;
  final String processName;
  final String? anonymousId;
  final String? userId;
  final Map<String, dynamic>? properties;

  const ProcessSubStartPayload({
    required this.parentProcessId,
    required this.processName,
    this.anonymousId,
    this.userId,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'parent_process_id': parentProcessId,
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

class ProcessFailPayload {
  final String processId;
  final String? reason;

  const ProcessFailPayload({required this.processId, this.reason});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'process_id': processId};
    if (reason != null) json['reason'] = reason;
    return json;
  }
}

class ProcessCancelPayload {
  final String processId;
  final String? reason;

  const ProcessCancelPayload({required this.processId, this.reason});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'process_id': processId};
    if (reason != null) json['reason'] = reason;
    return json;
  }
}

enum ProcessReversalKind { refund, chargeback, returnItem, other }

extension ProcessReversalKindWire on ProcessReversalKind {
  String get wire {
    switch (this) {
      case ProcessReversalKind.refund:
        return 'refund';
      case ProcessReversalKind.chargeback:
        return 'chargeback';
      case ProcessReversalKind.returnItem:
        return 'return';
      case ProcessReversalKind.other:
        return 'other';
    }
  }
}

class ProcessReversePayload {
  final String processId;
  final ProcessReversalKind kind;
  final String? reason;
  final double? amount;
  final String? currency;
  final Map<String, dynamic>? properties;

  const ProcessReversePayload({
    required this.processId,
    required this.kind,
    this.reason,
    this.amount,
    this.currency,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'process_id': processId,
      'kind': kind.wire,
    };
    if (reason != null) json['reason'] = reason;
    if (amount != null) json['amount'] = amount;
    if (currency != null) json['currency'] = currency;
    if (properties != null) json['properties'] = properties;
    return json;
  }
}
