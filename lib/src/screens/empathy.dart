import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmpathyScreen extends StatelessWidget {
  const EmpathyScreen({super.key, required this.title, required this.message, required this.id});

  final String title;
  final int id;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        // Centerウィジェットを追加
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 余白を追加
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 縦方向の間隔を均等に配置
            crossAxisAlignment: CrossAxisAlignment.center, // 横方向の中央に配置
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24.0, // テキストのサイズを大きく設定
                  fontWeight: FontWeight.bold, // 太字に設定（オプション）
                ),
              ),
              const SizedBox(height: 16.0), // 余白を追加
              ElevatedButton(
                onPressed: () {
                  // ボタンが押されたときの処理をここに追加
                  log('共感するボタンが押されました');
                  // このmessageのgood数を増やす
                  try {
                    final client = Supabase.instance.client;
                    client.rpc('increment',
                        params: {"x": 1, "row_id": id}).then((data) {
                      log('Gooded message: $data', name: 'supabase');
                    });
                  } catch (e) {
                    log('Failed to good message', name: 'supabase', error: e);
                  }
                },
                child: const Text('共感する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 使用例
// void main() {
//   runApp(MaterialApp(
//     home: EmpathyScreen(
//       title: '共感', // タイトルを変更
//       message: 'これは共感のメッセージです。', // メッセージを変更
//     ),
//   ));
// }
