import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/mypage.dart';
import 'screens/insert.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // Flutter公式サイトThemeを設定
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF94FFD8)),
        useMaterial3: true,
        // NavigationBarのテーマを設定
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(color: Color(0xFFFDFFC2)),
          ),
        ),
      ),
      // NavigaionBarのClassを呼び出す
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  // 各画面のリスト
  static const _screens = [
    HomeScreen(),
    MapScreen(),
    SettingScreen()
  ];
  // 選択されている画面のインデックス
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      // 本題のNavigationBar
      bottomNavigationBar: NavigationBar(
        // タップされたタブのインデックスを設定（タブ毎に画面の切り替えをする）
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // 選択されているタブの色（公式サイトのまま黄色）
        indicatorColor: Colors.amber,
        // 背景色を設定
        backgroundColor: Color(0xFF94FFD8),
        // 選択されたタブの設定（設定しないと画面は切り替わってもタブの色は変わらないです）
        selectedIndex: _selectedIndex,
        // タブ自体の設定（必須項目のため、書かないとエラーになります）
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.white),
            icon: Icon(Icons.home_outlined, color: Color(0xFFFDFFC2)),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.edit, color: Colors.white),
            icon: Icon(Icons.edit_outlined, color: Color(0xFFFDFFC2)),
            label: 'Messeage',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_outline, color: Colors.white),
            icon: Icon(Icons.person_outline, color: Color(0xFFFDFFC2)),
            label: 'Mypage',
          ),
        ],
      )
    );
  }
}
