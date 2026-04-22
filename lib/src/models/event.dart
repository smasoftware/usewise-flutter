class ElementData {
  final String? tag;
  final String? text;
  final String? id;

  const ElementData({this.tag, this.text, this.id});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (tag != null) json['tag'] = tag;
    if (text != null) json['text'] = text;
    if (id != null) json['id'] = id;
    return json;
  }
}

class PageData {
  final String? url;
  final String? title;
  final String? referrer;

  const PageData({this.url, this.title, this.referrer});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (url != null) json['url'] = url;
    if (title != null) json['title'] = title;
    if (referrer != null) json['referrer'] = referrer;
    return json;
  }
}

class ScreenData {
  final int? width;
  final int? height;

  const ScreenData({this.width, this.height});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    return json;
  }
}

class DeviceContextData {
  final String? deviceOs;
  final String? deviceModel;
  final String? appVersion;
  final bool? isVpn;
  final bool? isJailbroken;

  const DeviceContextData({
    this.deviceOs,
    this.deviceModel,
    this.appVersion,
    this.isVpn,
    this.isJailbroken,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (deviceOs != null) json['device_os'] = deviceOs;
    if (deviceModel != null) json['device_model'] = deviceModel;
    if (appVersion != null) json['app_version'] = appVersion;
    if (isVpn != null) json['is_vpn'] = isVpn;
    if (isJailbroken != null) json['is_jailbroken'] = isJailbroken;
    return json;
  }
}

class TrackEvent {
  final String event;
  final String? anonymousId;
  final String? userId;
  final String eventUuid;
  final String timestamp;
  final Map<String, dynamic>? properties;
  final ElementData? element;
  final PageData? page;
  final ScreenData? screen;
  final DeviceContextData? context;

  const TrackEvent({
    required this.event,
    this.anonymousId,
    this.userId,
    required this.eventUuid,
    required this.timestamp,
    this.properties,
    this.element,
    this.page,
    this.screen,
    this.context,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'event': event,
      'event_uuid': eventUuid,
      'timestamp': timestamp,
    };
    if (anonymousId != null) json['anonymous_id'] = anonymousId;
    if (userId != null) json['user_id'] = userId;
    if (properties != null) json['properties'] = properties;
    if (element != null) json['element'] = element!.toJson();
    if (page != null) json['page'] = page!.toJson();
    if (screen != null) json['screen'] = screen!.toJson();
    if (context != null) json['context'] = context!.toJson();
    return json;
  }
}
