import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class DeviceContext {
  final String deviceOS;
  final String deviceModel;
  final String appVersion;
  final bool isVpn;
  final bool isJailbroken;

  const DeviceContext({
    required this.deviceOS,
    required this.deviceModel,
    required this.appVersion,
    this.isVpn = false,
    this.isJailbroken = false,
  });

  Map<String, dynamic> toJson() => {
    'device_os': deviceOS,
    'device_model': deviceModel,
    'app_version': appVersion,
    'is_vpn': isVpn,
    'is_jailbroken': isJailbroken,
  };

  static Future<DeviceContext> capture() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceOS = Platform.operatingSystem;
    String deviceModel = 'unknown';

    try {
      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceOS = 'ios';
        deviceModel = ios.utsname.machine; // e.g. iPhone17,1
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceOS = 'android';
        deviceModel = '${android.manufacturer} ${android.model}';
      } else if (Platform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;
        deviceOS = 'macos';
        deviceModel = mac.model;
      } else if (Platform.isWindows) {
        deviceOS = 'windows';
        deviceModel = 'PC';
      } else if (Platform.isLinux) {
        deviceOS = 'linux';
        deviceModel = 'PC';
      }
    } catch (_) {}

    // App version
    String appVersion = '0.0.0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (_) {}

    // Jailbreak detection
    bool isJailbroken = false;
    try {
      isJailbroken = await FlutterJailbreakDetection.jailbroken;
    } catch (_) {}

    // VPN detection
    bool isVpn = false;
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        final name = iface.name.toLowerCase();
        if (name.contains('tun') ||
            name.contains('tap') ||
            name.contains('ppp') ||
            name.contains('ipsec') ||
            name.contains('utun') ||
            name.contains('wg')) {
          isVpn = true;
          break;
        }
      }
    } catch (_) {}

    return DeviceContext(
      deviceOS: deviceOS,
      deviceModel: deviceModel,
      appVersion: appVersion,
      isVpn: isVpn,
      isJailbroken: isJailbroken,
    );
  }
}
