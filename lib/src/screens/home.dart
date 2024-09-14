import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'empathy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  
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

  final List<Map<String, dynamic>> _scanResult = [];

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
          withMsd: [_msdFilterData],
          androidUsesFineLocation: true,
          continuousUpdates: true,
          removeIfGone: const Duration(seconds: 10));
    } catch (e) {
      log('Start scan Err', name: 'beacon', error: e);
    }

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResult.clear();
      });
      log('Scan results: $results', name: 'FlutterBluePlus');
      for (final result in results) {
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

        final id = int.parse('$major1$major2$minor1$minor2', radix: 16);
        final client = Supabase.instance.client;
        client.from('messages').select().eq('id', id).then((data) {
          setState(() {
            _scanResult.add(data.first);
          });
        });
      }
    }, onError: (e) {
      log('Scan error', name: 'FlutterBluePlus', error: e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ホーム',
        style: TextStyle(color: Colors.white), 
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _scanResult.length,
              itemBuilder: (context, index) {
                final result = _scanResult[index];

                log('result: $result');

                return Column(
                  children: [
                    ListTile(
                      title: Text(result['message']),
                      subtitle: Text(
                          'id: ${result['id']}, created_at: ${result['created_at']}'),
                      onTap: () {
                        try {
                          final client = Supabase.instance.client;
                          client.rpc('increment', params: {
                            "x": 1,
                            "row_id": result['id']
                          }).then((data) {
                            log('Gooded message: $data', name: 'supabase');
                          });
                        } catch (e) {
                          log('Failed to good message',
                              name: 'supabase', error: e);
                        }
                      },
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    SizedBox(height: 10), // 隙間を追加
                  ],
                );
              },
            ),
            ListTile(
              title: Text("aaaa"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmpathyScreen(title: 'Empathy', message: 'aaaa'),

                  ),
                );
              },
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            SizedBox(height: 10), // 隙間を追加
            ListTile(
              title: Text("bbbb"),
              onTap: () {},
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            SizedBox(height: 10), // 隙間を追加
            ListTile(
              title: Text("cccc"),
              onTap: () {},
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            SizedBox(height: 10), // 隙間を追加
          ],
        ),
      ),
    );
  }
}