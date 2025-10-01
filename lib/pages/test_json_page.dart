import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestJsonPage extends StatefulWidget {
  const TestJsonPage({super.key});

  @override
  State<TestJsonPage> createState() => _TestJsonPageState();
}

class _TestJsonPageState extends State<TestJsonPage> {
  String output = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final data = await rootBundle.loadString('assets/surah_info.json');
      final jsonResult = json.decode(data);
      setState(() {
        output = jsonResult["1"]["name"]; // should display "Al-Fatihah"
      });
    } catch (e) {
      setState(() {
        output = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test JSON Loader")),
      body: Center(child: Text(output)),
    );
  }
}
