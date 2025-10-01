import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'pages/favorites_page.dart';
import 'pages/reciters_page.dart';
import 'pages/help_page.dart';
import 'pages/test_json_page.dart'; // <-- idagdag ito

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
      home: const SplashPage(),
    //  home: TestJsonPage(),
      routes: {
        "/favorites": (_) => const FavoritesPage(),
        "/reciters": (_) => const RecitersPage(),
        "/help": (_) => const HelpPage(),
      },
    );
  }
}
