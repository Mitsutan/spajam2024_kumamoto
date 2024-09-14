import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  late SharedPreferences _sp;

  List<String> _myMassages = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      _sp = await SharedPreferences.getInstance();
      _myMassages = _sp.getStringList("MY_MESSAGE_ID") ?? [];
    } catch (e) {
      log('Failed to initialize scanning', name: 'beacon', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'マイページ',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                itemCount: _myMassages.length,
                itemBuilder: (context, index) {
                  final id = int.parse(_myMassages[index]);

                  // supabaseからidに対応するメッセージを取得
                  final supabase = Supabase.instance.client;
                  return FutureBuilder(
                    future: supabase.from('messages').select().eq('id', id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final data = snapshot.data;
                      return ListTile(
                        title: Text(data?.first['message']),
                        subtitle: Text(data?.first['created_at']),
                      );
                    },
                  );
                },
              ))
            ],
          ),
        ));
  }
}
