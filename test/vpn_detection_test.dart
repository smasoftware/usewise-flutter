import 'package:flutter_test/flutter_test.dart';
import 'package:usewise_flutter/src/utils/device_context.dart';

void main() {
  group('DeviceContext.looksLikeVpn', () {
    group('iOS false positives (the bug this fixes)', () {
      test('a bare utun interface is not a VPN', () {
        expect(DeviceContext.looksLikeVpn(['utun0']), isFalse);
      });

      test('a typical iPhone with no VPN is not flagged', () {
        expect(
          DeviceContext.looksLikeVpn(
            ['lo0', 'en0', 'pdp_ip0', 'utun0', 'utun1', 'utun2'],
          ),
          isFalse,
        );
      });

      test('iCloud Private Relay does not read as a VPN', () {
        expect(DeviceContext.looksLikeVpn(['en0', 'utun3']), isFalse);
      });

      test('utun is matched by prefix, not substring', () {
        // The old code used contains('tun'), so every utun matched twice over.
        expect(DeviceContext.looksLikeVpn(['utun0']), isFalse);
        expect(DeviceContext.looksLikeVpn(['UTUN0']), isFalse);
      });
    });

    group('real VPN interfaces are still detected', () {
      test('Android tun0 -- prefix tun still matches, utun does not', () {
        expect(DeviceContext.looksLikeVpn(['wlan0', 'tun0']), isTrue);
      });

      test('WireGuard on Android', () {
        expect(DeviceContext.looksLikeVpn(['wg0']), isTrue);
      });

      test('IPsec', () {
        expect(DeviceContext.looksLikeVpn(['ipsec0']), isTrue);
      });

      test('PPP and PPTP', () {
        expect(DeviceContext.looksLikeVpn(['ppp0']), isTrue);
        expect(DeviceContext.looksLikeVpn(['pptp0']), isTrue);
      });

      test('TAP', () {
        expect(DeviceContext.looksLikeVpn(['tap0']), isTrue);
      });

      test('matching is case insensitive', () {
        expect(DeviceContext.looksLikeVpn(['TUN0']), isTrue);
      });
    });

    group('edges', () {
      test('no interfaces is not a VPN', () {
        expect(DeviceContext.looksLikeVpn([]), isFalse);
      });

      test('a name merely containing a prefix does not match', () {
        expect(DeviceContext.looksLikeVpn(['mytun0', 'rmnet_data0']), isFalse);
      });

      test('a typical Android device with no VPN is not flagged', () {
        expect(
          DeviceContext.looksLikeVpn(['lo', 'wlan0', 'rmnet_data0', 'dummy0']),
          isFalse,
        );
      });
    });
  });
}
