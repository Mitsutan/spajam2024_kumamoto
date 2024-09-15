import 'dart:developer';
import 'dart:math' as math;

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

  void _startScan() async {
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

  void _stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      log('Stop scan Err', name: 'beacon', error: e);
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'みんなの感情',
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
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/アートボード ${(math.Random().nextInt(5)+1)}.png'),
                      ),
                      title: Text(result['message'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                      // subtitle: Text(
                      //     'id: ${result['id']}, created_at: ${result['created_at']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmpathyScreen(
                                title: 'Empathy',id: result['id'], message: result['message']),
                          ),
                        );
                        //   try {
                        //     final client = Supabase.instance.client;
                        //     client.rpc('increment', params: {
                        //       "x": 1,
                        //       "row_id": result['id']
                        //     }).then((data) {
                        //       log('Gooded message: $data', name: 'supabase');
                        //     });
                        //   } catch (e) {
                        //     log('Failed to good message',
                        //         name: 'supabase', error: e);
                        //   }
                      },
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    const SizedBox(height: 10), // 隙間を追加
                  ],
                );
              },
            ),
            // ListTile(
            //   title: Text("aaaa"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             EmpathyScreen(title: 'Empathy', message: 'aaaa'),
            //       ),
            //     );
            //   },
            // ),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            // SizedBox(height: 10), // 隙間を追加
            // ListTile(
            //   title: Text("bbbb"),
            //   onTap: () {},
            // ),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            // SizedBox(height: 10), // 隙間を追加
            // ListTile(
            //   title: Text("cccc"),
            //   onTap: () {},
            // ),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            // SizedBox(height: 10), // 隙間を追加
          ],
        ),
      ),
      floatingActionButton: FlutterBluePlus.isScanningNow
          ? FloatingActionButton(
              onPressed: () {
                _stopScan();
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            )
          : FloatingActionButton(
              onPressed: () {
                _startScan();
              },
              child: const Icon(Icons.bluetooth_searching),
            ),
    );
  }
}
