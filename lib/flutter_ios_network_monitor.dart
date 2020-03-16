import 'dart:async';

import 'package:flutter/services.dart';

class FlutterIosNetworkMonitor {
  static const MethodChannel _channel =
      const MethodChannel('plugin/flutter_ios_network_monitor');

  static EventChannel get createEventChannel =>
    EventChannel('plugin/flutter_ios_network_monitor/notify');

  static Future<Map<dynamic, dynamic>> get ipv4NetworkInfo async {
    final Map<dynamic, dynamic> pairs = await _channel.invokeMethod('getIPv4NetworkInfo');
    return pairs;
  }
}
