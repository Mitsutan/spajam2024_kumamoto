import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ホーム',
        style: TextStyle(color: Colors.white), 
      ),
      ),
      body: const Center(
          child: Text('Home画面', style: TextStyle(fontSize: 32.0))
      ),
    );
  }
}
