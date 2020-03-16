import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ios_network_monitor/flutter_ios_network_monitor.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_ios_network_monitor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterIosNetworkMonitor.platformVersion, '42');
  });
}
