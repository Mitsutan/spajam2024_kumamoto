import 'package:flutter/material.dart';

class EmpathyScreen extends StatelessWidget {
  const EmpathyScreen({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center( // Centerウィジェットを追加
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 余白を追加
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 縦方向の間隔を均等に配置
            crossAxisAlignment: CrossAxisAlignment.center, // 横方向の中央に配置
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 24.0, // テキストのサイズを大きく設定
                  fontWeight: FontWeight.bold, // 太字に設定（オプション）
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // ボタンが押されたときの処理をここに追加
                  print('共感するボタンが押されました');
                },
                child: Text('共感する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 使用例
void main() {
  runApp(MaterialApp(
    home: EmpathyScreen(
      title: '共感', // タイトルを変更
      message: 'これは共感のメッセージです。', // メッセージを変更
    ),
  ));
}
