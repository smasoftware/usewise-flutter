class IdentifyPayload {
  final String anonymousId;
  final String userId;
  final Map<String, dynamic>? traits;

  const IdentifyPayload({
    required this.anonymousId,
    required this.userId,
    this.traits,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'anonymous_id': anonymousId,
      'user_id': userId,
    };
    if (traits != null) json['traits'] = traits;
    return json;
  }
}
