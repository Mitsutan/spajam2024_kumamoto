import 'dart:developer';

import 'package:flutter/material.dart';
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
        title: const Text('メッセージ登録',style: TextStyle(color: Colors.white),),
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
          ])
    ));
  }
}
