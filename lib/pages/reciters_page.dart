import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class RecitersPage extends StatefulWidget {
  const RecitersPage({super.key});

  @override
  State<RecitersPage> createState() => _RecitersPageState();
}

class _RecitersPageState extends State<RecitersPage> {
  String _selectedReciter = "sudais";
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, String> reciters = {
    "sudais": "Abdurrahman As-Sudais",
    "afasy": "Mishary Rashid Alafasy",
    "ghamdi": "Saad Al-Ghamdi",
    "rifai": "Hani Ar-Rifai",
    "abdulbasit": "Abdulbasit Abdussamad",
    "menshawi": "Mohammed Siddiq Al-Menshawi",
    "fares": "Fares Abbad",
    "matroud": "Abdullah Matroud",
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedReciter();
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("selectedReciter");
    if (saved != null && reciters.containsKey(saved)) {
      setState(() => _selectedReciter = saved);
    }
  }

  Future<void> _saveSelectedReciter(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedReciter", reciterId);
  }

  String _mapReciterBaseUrl(String reciterId) {
    switch (reciterId) {
      case "sudais":
        return "https://verses.quran.com/Sudais/mp3/";
      case "afasy":
        return "https://verses.quran.com/Alafasy/mp3/";
      case "ghamdi":
        return "https://everyayah.com/data/Ghamadi_40kbps/";
      case "rifai":
        return "https://everyayah.com/data/Hani_Rifai_192kbps/";
      case "abdulbasit":
        return "https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/";
      case "menshawi":
        return "https://everyayah.com/data/Menshawi_32kbps/";
      case "fares":
        return "https://everyayah.com/data/Fares_Abbad_64kbps/";
      case "matroud":
        return "https://everyayah.com/data/Abdullah_Matroud_128kbps/";
      default:
        return "https://verses.quran.com/Sudais/mp3/";
    }
  }

  Future<void> _previewReciter(String reciterId) async {
    final baseUrl = _mapReciterBaseUrl(reciterId);
    // Surah 001 Ayah 001 (Al-Fatihah:1)
    final url = "${baseUrl}002002.mp3";

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Playing preview: ${reciters[reciterId]}",
            style: GoogleFonts.merriweather(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error playing preview: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        title: Text(
          "Reciters & Audio",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Choose your preferred reciter. This will be used across the app whenever you play Qur’an audio. You can also preview their recitation.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(color: Colors.white24),

          // Reciter list
          ...reciters.entries.map((entry) {
            final id = entry.key;
            final name = entry.value;
            return ListTile(
              title: Text(
                name,
                style: GoogleFonts.merriweather(color: Colors.white),
              ),
              leading: Radio<String>(
                activeColor: Colors.amber,
                value: id,
                groupValue: _selectedReciter,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedReciter = val);
                    _saveSelectedReciter(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "$name selected",
                          style: GoogleFonts.merriweather(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                            bottom: 60, left: 16, right: 16),
                      ),
                    );
                  }
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.amber),
                tooltip: "Preview Recitation",
                onPressed: () => _previewReciter(id),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
