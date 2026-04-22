import 'dart:ui' as ui;
import 'package:usewise_flutter/src/models/event.dart';

class ScreenInfo {
  static ScreenData capture() {
    try {
      final views = ui.PlatformDispatcher.instance.views;
      if (views.isEmpty) return const ScreenData();

      final view = views.first;
      final size = view.physicalSize;
      final ratio = view.devicePixelRatio;

      if (ratio == 0 || size.isEmpty) return const ScreenData();

      return ScreenData(
        width: (size.width / ratio).round(),
        height: (size.height / ratio).round(),
      );
    } catch (_) {
      return const ScreenData();
    }
  }
}
