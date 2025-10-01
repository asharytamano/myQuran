import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/tajweed_widget.dart';

class TajweedPage extends StatefulWidget {
  const TajweedPage({super.key});

  @override
  State<TajweedPage> createState() => _TajweedPageState();
}

class _TajweedPageState extends State<TajweedPage> {
  List<dynamic> ayahs = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await rootBundle.loadString('assets/data/fatihah_tajweed.json');
    final jsonData = json.decode(data);
    setState(() {
      ayahs = jsonData['ayahs'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Surah Al-Fatihah (Tajweed Demo)"),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
      ),
      body: ayahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ayahs.length,
        itemBuilder: (context, index) {
          final ayah = ayahs[index];
          final spans = List<Map<String, dynamic>>.from(ayah['tajweed']);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TajweedAyahWidget(spans: spans, fontSize: 28),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ayah ${ayah['ayah_number']}",
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
