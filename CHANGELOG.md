## 2.9.1 (2026-09-05)

- Fix `is_vpn` reporting true for most iPhones. VPN detection matched interface
  names with `contains`, so iOS `utunN` interfaces matched the `tun` entry (and
  the redundant `utun` entry) even with no VPN present -- iCloud Private Relay,
  Wi-Fi Calling, Handoff and Personal Hotspot all create them. In production
  this read as VPN on 77.5% of iOS sessions against 1.0% on Android.
  Matching is now by prefix, which fixes iOS without weakening Android: `utun0`
  does not start with `tun`, while Android's real `tun0` and `wg0` still match.
  On iOS this trades recall for precision -- VPNs tunnelling over `utun`
  (WireGuard, IKEv2, most commercial apps) are no longer detected -- so `is_vpn`
  now under-reports there rather than over-reporting.
- Add `DeviceContext.looksLikeVpn()`, the pure check, covered by 13 tests.

## 2.9.0 (2026-05-02)

- Add `cancelProcess()` for user-initiated abandonment (separate from `failProcess`)
- Add `reverseProcess()` for refunds, chargebacks, and returns on completed processes

## 0.1.1 (2026-04-20)

- Release 0.1.1

## 0.1.0

- Initial release
- Event tracking with auto-batching
- User identification (anonymous + authenticated)
- Process/funnel tracking (start, step, complete)
- Automatic screen size capture
- Anonymous ID persistence via SharedPreferences
- Retry with exponential backoff
- Opt-out/opt-in support
