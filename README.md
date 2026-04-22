# usewise_flutter

Official Flutter SDK for [Usewise](https://usewise.io) product analytics.

## Features

- Event tracking with automatic batching
- User identification (anonymous + authenticated)
- Process/funnel tracking (start, step, complete)
- Automatic screen size capture
- Anonymous ID persistence
- Retry with exponential backoff
- Opt-out/opt-in support

## Installation

```yaml
dependencies:
  usewise_flutter: ^0.1.0
```

## Quick Start

### Initialize

```dart
import 'package:usewise_flutter/usewise_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Usewise.init(UsewiseConfig(
    apiKey: 'uw_live_your_api_key_here',
    baseUrl: 'https://api.usewise.io/api/v1',
  ));

  runApp(MyApp());
}
```

### Track Events

```dart
// Simple event
Usewise.instance.track('button_click');

// With properties
Usewise.instance.track('purchase', properties: {
  'product_id': 'SKU-123',
  'price': 29.99,
  'currency': 'USD',
});

// With page context
Usewise.instance.track('page_view', page: PageData(
  url: '/products/123',
  title: 'Product Detail',
));
```

### Identify Users

```dart
// After login, link anonymous activity to authenticated user
await Usewise.instance.identify('user_456', traits: {
  'name': 'Jane Smith',
  'plan': 'pro',
});
```

### Track Processes (Funnels)

```dart
// Start a checkout process
final processId = await Usewise.instance.startProcess('checkout');

// Record steps
await Usewise.instance.processStep(processId, 'cart_review');
await Usewise.instance.processStep(processId, 'shipping_info');
await Usewise.instance.processStep(processId, 'payment');

// Complete
await Usewise.instance.completeProcess(processId);
```

### Logout / Reset

```dart
// On user logout — generates new anonymous ID, clears queue
await Usewise.instance.reset();
```

### Opt-Out

```dart
// Respect user privacy preferences
await Usewise.instance.optOut();  // stops all tracking
await Usewise.instance.optIn();   // re-enables tracking
```

### Shutdown

```dart
// Clean shutdown — flushes pending events
await Usewise.instance.shutdown();
```

## Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `apiKey` | required | Your Usewise API key |
| `baseUrl` | `https://api.usewise.io` | API base URL |
| `flushIntervalMs` | `30000` | Auto-flush interval in ms |
| `flushAt` | `20` | Flush when queue reaches this size |
| `maxQueueSize` | `1000` | Max queued events (oldest dropped) |
| `maxRetries` | `3` | HTTP retry attempts |
| `httpTimeout` | `10s` | HTTP request timeout |
| `enableLogging` | `false` | Print debug logs |

## How It Works

- **Events are queued** in memory and flushed in batches (via `/v1/batch`)
- **Sessions are server-side** — the SDK does not manage sessions
- **Anonymous ID** is generated on first launch and persisted via SharedPreferences
- **Failed flushes** keep events in the queue for the next cycle
- **Screen dimensions** are automatically captured with each event
