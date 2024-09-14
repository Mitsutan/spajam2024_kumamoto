import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      await flutterBeacon.initializeScanning;
    } on PlatformException catch (e) {
      log('Failed to initialize scanning', name: 'beacon', error: e);
    }
  }

  void _startBeacon() async {
    try {
      await flutterBeacon.startBroadcast(BeaconBroadcast(
          proximityUUID: "124586a6-8b4f-213b-0a00-3098e304ed50",
          major: 0,
          minor: 5,
          identifier: "dev.mitsutan.spajam2024_kumamoto"));
    } catch (e) {
      log('Start broadcast error', name: 'beacon', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startBeacon,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
