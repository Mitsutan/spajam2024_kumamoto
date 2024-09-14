import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('メッセージ登録',style: TextStyle(color: Colors.white),),
      ),
      body: const Center(
          child: Text('Map画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}
