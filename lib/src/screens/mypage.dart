import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('マイページ',style: TextStyle(color: Colors.white),),
      ),
      body: const Center(
          child: Text('Setting画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}
