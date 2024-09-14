import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://gfcpqnvcucjkjdgkaetw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmY3BxbnZjdWNqa2pkZ2thZXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYzMDA1OTgsImV4cCI6MjA0MTg3NjU5OH0.T7AhkjJVZKQa0nx7LsV4ZP_kmqGuMWUq_H7G1K12Xb0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      // Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      // Permission.bluetooth
    ].request();
    log(statuses.toString(), name: 'PermissionStatus');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    requestPermission();
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
  final MsdFilter _msdFilterData = MsdFilter(76, data: [
    0x02,
    0x15,
    0x97,
    0xb7,
    0x57,
    0x1b,
    0x57,
    0x18,
    0xbc,
    0x11,
    0xa7,
    0xd3,
    0x86,
    0x02,
    0x4c,
    0xda,
    0x3b,
    0x5c
  ], mask: [
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  ]);

  String _major = '0000';
  String _minor = '0000';

  final List<Map<String, dynamic>> _scanResult = [];

  String _inputMsg = '';

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

  void _startBeacon(String major, String minor) async {
    try {
      final isBroadcasting = await flutterBeacon.isBroadcasting();

      if (isBroadcasting) {
        await flutterBeacon.stopBroadcast();
        setState(() {
          _scanResult.clear();
        });
      }

      await flutterBeacon.startBroadcast(BeaconBroadcast(
          proximityUUID: "97b7571b-5718-bc11-a7d3-86024cda3b5c",
          major: int.parse(major, radix: 16),
          minor: int.parse(minor, radix: 16),
          identifier: "dev.mitsutan.spajam2024_kumamoto"));
    } catch (e) {
      log('Start broadcast error', name: 'beacon', error: e);
    }

    try {
      await FlutterBluePlus.startScan(
          withMsd: [_msdFilterData], androidUsesFineLocation: true, continuousUpdates: true, removeIfGone: const Duration(seconds: 10));
    } catch (e) {
      log('Start scan Err', name: 'beacon', error: e);
    }

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResult.clear();
      });
      log('Scan results: $results', name: 'FlutterBluePlus');
      for (final result in results) {
        // log('Scan result: ${result.advertisementData.manufacturerData}', name: 'FlutterBluePlus');
        if (result.advertisementData.manufacturerData.isEmpty) {
          continue;
        }
        final major1 = result.advertisementData.manufacturerData.values.first
            .elementAt(18)
            .toRadixString(16);
        final major2 = result.advertisementData.manufacturerData.values.first
            .elementAt(19)
            .toRadixString(16);
        final minor1 = result.advertisementData.manufacturerData.values.first
            .elementAt(20)
            .toRadixString(16);
        final minor2 = result.advertisementData.manufacturerData.values.first
            .elementAt(21)
            .toRadixString(16);
        // log('major: $major1$major2, minor: $minor1$minor2');

        // major, minorをidに変換しmessageを取得
        final id = int.parse('$major1$major2$minor1$minor2', radix: 16);
        final client = Supabase.instance.client;
        client.from('messages').select().eq('id', id).then((data) {
          // log('Message: ${data.first}', name: 'supabase');
          // _scanResult.add(data.first);
          setState(() {
            _scanResult.add(data.first);
          });
        });
      }

    }, onError: (e) {
      log('Scan error', name: 'FlutterBluePlus', error: e);
    });
  }

  void _postMessage(String msg) async {
    final client = Supabase.instance.client;
    try {
      final data = await client.from('messages').upsert({
        'message': msg,
      }).select();
      // idを16進数に変換
      final id = data.first['id'].toRadixString(16).padLeft(8, '0');
      setState(() {
        _major = id.substring(0, 4);
        _minor = id.substring(4, 8);
      });
      log('Posted message: ${data.first['id']}', name: 'supabase');
      // log('Posted message: $id', name: 'supabase');
    } catch (e) {
      log('Failed to post message', name: 'supabase', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'input message',
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Enter your text here",
              ),
              onChanged: (value) {
                setState(() {
                  _inputMsg = value;
                });
              },
            ),
            IconButton(
                onPressed: () {
                  _postMessage(_inputMsg);
                },
                icon: const Icon(Icons.send)),
            Expanded(
              child: ListView.builder(
                  itemCount: _scanResult.length,
                  itemBuilder: (context, index) {
                    final result = _scanResult[index];

                    log('result: $result');

                    return ListTile(
                      title: Text(result['message']),
                      subtitle: Text('id: ${result['id']}, created_at: ${result['created_at']}'),
                      onTap: () {
                        // このmessageのgood数を増やす
                        try {
                          final client = Supabase.instance.client;
                        client.rpc('increment',  params: { "x": 1, "row_id": result['id'] }).then((data) {
                          log('Gooded message: $data', name: 'supabase');
                        });
                        } catch (e) {
                          log('Failed to good message', name: 'supabase', error: e);
                        }
                        
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startBeacon(_major, _minor),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
