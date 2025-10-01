import 'package:flutter/material.dart';
import 'splash_page.dart';

void main() {
  runApp(const MaranawTafsirApp());
}

class MaranawTafsirApp extends StatelessWidget {
  const MaranawTafsirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maranao Tafsir',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SplashPage(), // ✅ balik splash page
    );
  }
}
