import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_ios_network_monitor/flutter_ios_network_monitor.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _str = 'Unknown';

  @override
  void initState() {
    super.initState();
    // Starting to listen eventChannel for network changed.
    EventChannel eventChannel = FlutterIosNetworkMonitor.eventChannel;
    eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  void _onEvent(Object event) {
    if (event is List) {
      setState(() {
        _str = event.join(',');
      });
    } else if (event is String){
      setState(() {
        _str = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_str\n'),
        ),
      ),
    );
  }
}
