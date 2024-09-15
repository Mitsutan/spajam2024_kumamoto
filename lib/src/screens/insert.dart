import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({super.key, required this.title});

  final String title;

  @override
  State<InsertScreen> createState() => _InsertScreen();
}

class _InsertScreen extends State<InsertScreen> {
  String _inputMsg = '';

  String _major = '0000';
  String _minor = '0000';

  late SharedPreferences _sp;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      _sp = await SharedPreferences.getInstance();
    } catch (e) {
      log('Failed to initialize sharedpref', name: 'sharedpref', error: e);
    }
  }

  void _startBeacon(String major, String minor) async {
    try {
      final isBroadcasting = await flutterBeacon.isBroadcasting();

      if (isBroadcasting) {
        await flutterBeacon.stopBroadcast();
        // setState(() {
        //   _scanResult.clear();
        // });
      }

      await flutterBeacon.startBroadcast(BeaconBroadcast(
          proximityUUID: "97b7571b-5718-bc11-a7d3-86024cda3b5c",
          major: int.parse(major, radix: 16),
          minor: int.parse(minor, radix: 16),
          identifier: "dev.mitsutan.spajam2024_kumamoto"));
    } catch (e) {
      log('Start broadcast error', name: 'beacon', error: e);
    }
  }

  void _postMessage(String msg) async {
    final client = Supabase.instance.client;
    try {
      final data = await client.from('messages').upsert({
        'message': msg,
      }).select();
      // idを16進数に変換
      final id = data.first['id'].toRadixString(16).padLeft(8, '0');
      await _sp.setStringList("MY_MESSAGE_ID", [
        ...?_sp.getStringList("MY_MESSAGE_ID"),
        data.first['id'].toString()
      ]);
      setState(() {
        _major = id.substring(0, 4);
        _minor = id.substring(4, 8);
      });
      log('Posted message: ${data.first['id']}', name: 'supabase');

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('投稿完了')), // タイトルを中央に配置
              content: const SizedBox(
                width: 100, // コンテンツの幅を指定
                height: 100, // コンテンツの高さを指定して正方形に近づける
                child: Center(child: Text('投稿されました')), // コンテンツを中央に配置
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 20.0), // パディングを調整してコンパクトにする
              actionsPadding: const EdgeInsets.only(
                  bottom: 10.0), // アクションのパディングを調整して間隔を小さくする
              actions: <Widget>[
                Center(
                  child: TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      _startBeacon(_major, _minor);
                      Navigator.of(context).pop(); // ダイアログを閉じる
                      Navigator.of(context)
                          .pushReplacementNamed('/'); // main.dartに遷移
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(builder: (context) => HomeScreen(title: "home")), // ホーム画面に遷移
                      // );
                    },
                  ),
                ),
              ],
            );
          },
        );
      }

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
        title: const Text(
          'メッセージ登録',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            // const Text(
            //   'input message',
            // ),
            SizedBox(
              width: 300, // テキストフィールドの横幅を指定
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "周りに共有したい感情を入力してください",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // フォーカス時の枠線の色を黒に設定
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _inputMsg = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _postMessage(_inputMsg);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA4A4), // ボタンの背景色
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0), // パディングを追加してボタンを大きくする
                minimumSize: const Size(150, 50), // 最小サイズを設定
              ),
              child: const Text(
                '投稿',
                style: TextStyle(color: Colors.white), // テキストの色を黄色に設定
              ),
            ),
          ])),
    );
  }
}
