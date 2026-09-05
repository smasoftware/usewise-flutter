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


  /// Interface-name prefixes that indicate a VPN.
  ///
  /// Deliberately excludes `utun`. iOS creates `utunN` interfaces with no VPN
  /// present -- iCloud Private Relay, Wi-Fi Calling, Handoff and Personal
  /// Hotspot all do it -- so treating `utun` as proof of a VPN flags most
  /// iPhones. In production it read as VPN on 77.5% of iOS sessions against
  /// 1.0% on Android.
  ///
  /// Note that `tun` is kept: matching is by prefix, and `utun0` does not
  /// start with `tun`, while Android's real VPN interface `tun0` does. That is
  /// why the old code was wrong -- it used `contains`, so `tun` matched every
  /// `utun` on iOS and the separate `utun` entry matched them a second time.
  ///
  /// The trade is precision over recall on iOS: VPNs tunnelling over `utun`
  /// (WireGuard, IKEv2, most commercial apps) are no longer detected there, so
  /// is_vpn now under-reports on iOS rather than over-reporting. For a signal
  /// used to judge a user, a false positive accuses someone while a false
  /// negative merely says nothing. Android is unaffected and still detects
  /// `tun0` and `wg0`.
  ///
  /// Treat this as a weak hint and lean on server-derived proxy/IP signals for
  /// anything that gates a user.
  static const vpnInterfacePrefixes = [
    'tun',
    'tap',
    'ppp',
    'pptp',
    'ipsec',
    'wg',
  ];

  /// Pure part of the check, split out so it can be tested without a device.
  static bool looksLikeVpn(Iterable<String> interfaceNames) {
    return interfaceNames.any((name) {
      final lower = name.toLowerCase();
      return vpnInterfacePrefixes.any(lower.startsWith);
    });
  }

  static Future<DeviceContext> capture() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceOS = Platform.operatingSystem;
    String deviceModel = 'unknown';

    try {
      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceOS = 'iOS ${ios.systemVersion}'; // e.g. iOS 17.4
        deviceModel = ios.utsname.machine; // e.g. iPhone17,1
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceOS = 'Android ${android.version.release}'; // e.g. Android 14
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
      isVpn = looksLikeVpn(interfaces.map((i) => i.name));
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
