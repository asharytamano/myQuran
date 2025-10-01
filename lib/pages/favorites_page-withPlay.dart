import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart'; // 🔹 Added for audio
import '../utils/bookmark_manager.dart';
import 'surah_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favorites = [];
  String selectedLanguage = "maranao";
  int? selectedIndex;

  final AudioPlayer _audioPlayer = AudioPlayer(); // 🔹 Keep one instance

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await BookmarkManager.getFavorites();
    setState(() {
      favorites = favs;
      selectedIndex = favorites.isNotEmpty ? favorites.length - 1 : null;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> ayah) async {
    await BookmarkManager.removeFavorite(
      ayah['surah_number'],
      ayah['ayah_number'],
    );
    await _loadFavorites();
  }

  String _getTranslation(Map<String, dynamic> ayah) {
    switch (selectedLanguage) {
      case "tagalog":
        return ayah['translation_tl'] ?? "—";
      case "bisayan":
        return ayah['translation_bis'] ?? "—";
      case "english":
        return ayah['translation_en'] ?? "—";
      case "maranao":
      default:
        return ayah['text_mn'] ?? "—";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox(),
              dropdownColor: Colors.black,
              style: GoogleFonts.merriweather(color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: "maranao",
                  child: Text("Maranao – Abu Ahmad Tamano"),
                ),
                DropdownMenuItem(
                  value: "tagalog",
                  child: Text("Tagalog – Rowwad Translation Center"),
                ),
                DropdownMenuItem(
                  value: "bisayan",
                  child: Text("Bisayan – Rowwad Translation Center"),
                ),
                DropdownMenuItem(
                  value: "english",
                  child: Text("English – Rowwad Translation Center"),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => selectedLanguage = val);
              },
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
        child: Text(
          "No favorites yet.",
          style: GoogleFonts.merriweather(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final ayah = favorites[index];
          final translation = _getTranslation(ayah);
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahDetailPage(
                    surahNumber: ayah['surah_number'],
                    surahNameEnglish: "Surah ${ayah['surah_number']}",
                    surahNameArabic: "",
                  ),
                ),
              );
            },
            child: Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.black.withOpacity(0.75),
              elevation: isSelected ? 10 : 2,
              shadowColor: isSelected
                  ? Colors.orangeAccent
                  : Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? Colors.orangeAccent
                      : Colors.orangeAccent.withOpacity(0.5),
                  width: isSelected ? 2 : 0.6,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Surah:Ayah badge
                    Text(
                      "${ayah['surah_number']}:${ayah['ayah_number']}",
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Arabic text
                    Text(
                      ayah['text_ar'] ?? "",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Translation
                    Text(
                      translation,
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        color: Colors.amber,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Action Row
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.shade700
                            : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6),
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ▶️ Play
                          IconButton(
                            iconSize: 20,
                            tooltip: "Play",
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.amber),
                            onPressed: () async {
                              final audioUrl = ayah['audioUrl'];
                              if (audioUrl != null &&
                                  audioUrl.isNotEmpty) {
                                await _audioPlayer
                                    .play(UrlSource(audioUrl));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "No audio available for this ayah"),
                                  ),
                                );
                              }
                            },
                          ),

                          // 📋 Copy
                          IconButton(
                            iconSize: 20,
                            tooltip: "Copy",
                            icon: const Icon(Icons.copy,
                                color: Colors.blue),
                            onPressed: () {
                              final copyText =
                                  "${ayah['text_ar']}\n\n$translation\n\n(${ayah['surah_number']}:${ayah['ayah_number']})";
                              Clipboard.setData(
                                  ClipboardData(text: copyText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Ayah copied!"),
                                ),
                              );
                            },
                          ),

                          // 📤 Share
                          IconButton(
                            iconSize: 20,
                            tooltip: "Share",
                            icon: const Icon(Icons.share,
                                color: Colors.green),
                            onPressed: () {
                              final shareText =
                                  "${ayah['text_ar']}\n\n$translation\n\n(${ayah['surah_number']}:${ayah['ayah_number']})";
                              Share.share(shareText);
                            },
                          ),

                          // 🗑 Remove
                          IconButton(
                            iconSize: 20,
                            tooltip: "Remove",
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _removeFavorite(ayah),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
