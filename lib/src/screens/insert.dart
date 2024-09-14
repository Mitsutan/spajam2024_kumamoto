import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:spajam2024_kumamoto/src/screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

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
      
          showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('投稿完了')), // タイトルを中央に配置
                content: Container(
        width: 100, // コンテンツの幅を指定
        height: 100, // コンテンツの高さを指定して正方形に近づける
        child: Center(child: Text('投稿されました')), // コンテンツを中央に配置
        ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // パディングを調整してコンパクトにする
          actionsPadding: EdgeInsets.only(bottom: 10.0), // アクションのパディングを調整して間隔を小さくする
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen(title: "home")), // ホーム画面に遷移
                  );
                },
              ),
            ),
          ],
        );
      },
    );

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
        title: const Text('メッセージ登録',style: TextStyle(color: Colors.white),),
      ),
      body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Text(
            //   'input message',
            // ),
            Container(
            width: 300, // テキストフィールドの横幅を指定
            child:TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "共感したい感情を入力してください",
                enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black), // フォーカス時の枠線の色を黒に設定
              ),
            ),
              onChanged: (value) {
                setState(() {
                  _inputMsg = value;
                });
              },
            ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _postMessage(_inputMsg);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA4A4), // ボタンの背景色
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // パディングを追加してボタンを大きくする
                minimumSize: Size(150, 50), // 最小サイズを設定
              ),
              
              child: const Text(
                '投稿',
                style: TextStyle(color: Colors.white), // テキストの色を黄色に設定
              ),
            ),
          ])
    ),
    );
  }
}
