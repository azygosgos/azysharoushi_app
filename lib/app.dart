import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class SharoushiApp extends StatelessWidget {
  const SharoushiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '社労士試験 学習アプリ',
      debugShowCheckedModeBanner: false,
      // ダークモードは将来対応の余地を残すため、Light/Darkの両方を定義しておく。
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
