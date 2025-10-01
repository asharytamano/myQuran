import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../utils/bookmark_manager.dart';
import '../utils/translation_loader.dart';
import '../utils/surah_info_loader.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayahs = [];
  bool loading = true;

  String selectedReciter = "sudais";
  final AudioPlayer _audioPlayer = AudioPlayer();

  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _itemKeys = [];

  int? currentlyPlayingAyah;
  bool isPlaying = false;
  bool continuousPlay = true;
  int? expandedAyahIndex;

  // repeat mode
  bool repeatAyah = false;
  bool repeatSurah = false;

  // language toggle
  String selectedLanguage = "maranao";

  // pagination
  int currentPage = 0;
  static const int pageSize = 50;

  // controls Surah Info box
  bool showOverview = true;

  // prevents end-of-surah repeat
  bool alreadyEnded = false;

  @override
  void initState() {
    super.initState();
    fetchSurah().then((_) async {
      await _mergeTranslation(QuranLanguage.tagalog, "translation_tl");
      await _mergeTranslation(QuranLanguage.bisayan, "translation_bis");
      await _mergeTranslation(QuranLanguage.english, "translation_en");
    });
    _loadReciterPref();

    _audioPlayer.onPlayerComplete.listen((_) {
      if (currentlyPlayingAyah != null) {
        if (repeatAyah) {
          _playAyah(ayahs[currentlyPlayingAyah!]['ayah_number'],
              index: currentlyPlayingAyah);
        } else if (repeatSurah) {
          final next = (currentlyPlayingAyah! + 1);
          if (next < ayahs.length) {
            _playAyah(ayahs[next]['ayah_number'], index: next);
          } else {
            _playAyah(ayahs.first['ayah_number'], index: 0);
          }
        } else if (continuousPlay) {
          final next = (currentlyPlayingAyah! + 1);
          if (next < ayahs.length) {
            _playAyah(ayahs[next]['ayah_number'], index: next);
          } else if (!alreadyEnded) {
            alreadyEnded = true; // 🔹 trigger once only
            setState(() => isPlaying = false);
            _playChimeAndShowSnackbar("End of Surah");
          }
        } else {
          setState(() => isPlaying = false);
        }
      }
    });
  }

  Future<void> _mergeTranslation(QuranLanguage lang, String fieldKey) async {
    final data = await TranslationLoader.load(lang, widget.surahNumber);
    if (data != null) {
      for (var i = 0; i < data.length && i < ayahs.length; i++) {
        if (data[i].containsKey("ayah_number")) {
          switch (lang) {
            case QuranLanguage.english:
              ayahs[i][fieldKey] = data[i]["text_en"] ?? "";
              break;
            case QuranLanguage.tagalog:
              ayahs[i][fieldKey] = data[i]["translation_tl"] ?? "";
              break;
            case QuranLanguage.bisayan:
              ayahs[i][fieldKey] = data[i]["translation_bis"] ?? "";
              break;
            case QuranLanguage.maranao:
              break; // already loaded
          }
        }
      }
      setState(() {});
    }
  }

  Future<void> _loadReciterPref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("selectedReciter");
    if (saved != null) {
      setState(() => selectedReciter = saved);
    }
  }

  Future<void> _saveReciterPref(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedReciter", reciterId);
  }

  Future<void> fetchSurah() async {
    final res = await http.get(Uri.parse(
        "https://maranaw.com/api/surah_json.php?surah=${widget.surahNumber}"));
    final data = json.decode(res.body);

    setState(() {
      ayahs = List<Map<String, dynamic>>.from(data['data']['ayahs']);
      if (ayahs.isNotEmpty && ayahs.first['ayah_number'] == 0) {
        ayahs.removeAt(0);
      }
      _itemKeys = List.generate(ayahs.length, (_) => GlobalKey());
      loading = false;
    });
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

  Future<void> _playAyah(int ayahNumber, {int? index}) async {
    final surahStr = widget.surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    final baseUrl = _mapReciterBaseUrl(selectedReciter);
    final url = "$baseUrl$surahStr$ayahStr.mp3";

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));

      setState(() {
        showOverview = false; // 🔹 fade out Surah Info
        alreadyEnded = false; // 🔹 reset flag
        currentlyPlayingAyah = index;
        isPlaying = true;
      });

      if (index != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _centerOnIndex(index));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Audio not available.",
              style: GoogleFonts.merriweather(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      showOverview = true; // 🔹 show Surah Info again
      isPlaying = false;
      currentlyPlayingAyah = null;
    });
  }

  Future<void> _centerOnIndex(int index) async {
    if (index < 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _playChimeAndShowSnackbar(String message) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource("sounds/bell-chime.mp3"));
    } catch (e) {
      debugPrint("Chime sound error: $e");
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (ayahs.length / pageSize).ceil();
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, ayahs.length);

    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.surahNameEnglish,
                style: GoogleFonts.merriweather(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "  (${widget.surahNameArabic})",
                style: GoogleFonts.amiri(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔹 Pagination controls (only if >50 ayahs)
          if (totalPages > 1)
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: currentPage > 0
                        ? () {
                      setState(() => currentPage--);
                      _playChimeAndShowSnackbar("Start of Surah");
                    }
                        : null,
                  ),
                  Text(
                    "${currentPage + 1}/$totalPages",
                    style: GoogleFonts.merriweather(
                        color: Colors.white, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: currentPage < totalPages - 1
                        ? () {
                      setState(() => currentPage++);
                    }
                        : () {
                      _playChimeAndShowSnackbar("End of Surah");
                    },
                  ),
                ],
              ),
            ),

          // 🔹 Language dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
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
                if (val != null) {
                  setState(() => selectedLanguage = val);
                }
              },
            ),
          ),

          // 🔹 Reciter + Play/Stop row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedReciter,
                    isExpanded: true,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: "sudais",
                        child: Text("Abdurrahman As-Sudais"),
                      ),
                      DropdownMenuItem(
                        value: "afasy",
                        child: Text("Mishary Rashid Alafasy"),
                      ),
                      DropdownMenuItem(
                        value: "ghamdi",
                        child: Text("Saad Al-Ghamdi"),
                      ),
                      DropdownMenuItem(
                        value: "rifai",
                        child: Text("Hani Ar-Rifai"),
                      ),
                      DropdownMenuItem(
                        value: "abdulbasit",
                        child: Text("Abdulbasit Abdussamad"),
                      ),
                      DropdownMenuItem(
                        value: "menshawi",
                        child: Text("Menshawi"),
                      ),
                      DropdownMenuItem(
                        value: "fares",
                        child: Text("Fares Abbad"),
                      ),
                      DropdownMenuItem(
                        value: "matroud",
                        child: Text("Abdullah Matroud"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedReciter = val);
                        _saveReciterPref(val);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  tooltip: "Play All",
                  onPressed: () {
                    if (ayahs.isNotEmpty) {
                      _playAyah(ayahs.first['ayah_number'], index: 0);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white),
                  tooltip: "Stop",
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ),
          const Divider(height: 0),

          // 🔹 Surah Overview box (auto-hide & remove space)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: showOverview
                ? FutureBuilder<Map<String, dynamic>>(
              future: SurahInfoLoader.load(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final info = snapshot.data!["${widget.surahNumber}"];
                if (info == null) return const SizedBox();

                return Card(
                  key: const ValueKey("overviewBox"), // 👈 important for switcher
                  color: Colors.black.withOpacity(0.75),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: Colors.orangeAccent, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${info['name']} (${widget.surahNameArabic})",
                          style: GoogleFonts.merriweather(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Type: ${info['type']} | Ayahs: ${info['ayah_count']}",
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info['overview'],
                          style: GoogleFonts.merriweather(
                            fontSize: 13,
                            color: Colors.amber,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : const SizedBox.shrink(), // 👈 removes it completely
          ),

          // 🔹 Bismillah (except Surah 9)
          if (widget.surahNumber != 9)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          // 🔹 Ayah list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: (endIndex - startIndex),
              itemBuilder: (context, idx) {
                final index = startIndex + idx;
                final ayah = ayahs[index];
                final bool isExpanded = expandedAyahIndex == index;
                final bool isThisPlaying =
                    index == currentlyPlayingAyah && isPlaying;

                return Card(
                  key: _itemKeys[index],
                  color: Colors.black87,
                  elevation: isThisPlaying ? 10 : 2,
                  shadowColor: isThisPlaying
                      ? Colors.orangeAccent
                      : Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isThisPlaying
                        ? const BorderSide(
                        color: Colors.orangeAccent, width: 2)
                        : BorderSide.none,
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔹 Ayah Number Badge
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${widget.surahNumber}:${ayah['ayah_number']}",
                              style: GoogleFonts.merriweather(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Arabic text
                        Text(
                          ayah['text_ar'] ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 24,
                            color: Colors.white,
                            height: 2.0,
                          ),
                        ),

                        // Translation (toggle)
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          Text(
                            selectedLanguage == "maranao"
                                ? (ayah['text_mn'] ?? "")
                                : selectedLanguage == "tagalog"
                                ? (ayah['translation_tl'] ?? "—")
                                : selectedLanguage == "bisayan"
                                ? (ayah['translation_bis'] ?? "—")
                                : (ayah['translation_en'] ?? "—"),
                            textAlign: TextAlign.left,
                            style: GoogleFonts.merriweather(
                              fontSize: 16,
                              color: Colors.orangeAccent,
                              height: 1.4,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Action Row
                        Container(
                          decoration: BoxDecoration(
                            color: isThisPlaying
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
                              // 📋 Copy
                              IconButton(
                                iconSize: 20,
                                tooltip: "Copy",
                                icon: const Icon(Icons.copy,
                                    color: Colors.blue),
                                onPressed: () {
                                  final copyText =
                                      "${ayah['text_ar']}\n\n${selectedLanguage == "maranao" ? (ayah['text_mn'] ?? "") : selectedLanguage == "tagalog" ? (ayah['translation_tl'] ?? "—") : selectedLanguage == "bisayan" ? (ayah['translation_bis'] ?? "—") : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                                  Clipboard.setData(
                                      ClipboardData(text: copyText));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text("Copied to clipboard"),
                                      duration: Duration(seconds: 2),
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
                                      "${ayah['text_ar']}\n\n${selectedLanguage == "maranao" ? (ayah['text_mn'] ?? "") : selectedLanguage == "tagalog" ? (ayah['translation_tl'] ?? "—") : selectedLanguage == "bisayan" ? (ayah['translation_bis'] ?? "—") : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                                  Share.share(shareText);
                                },
                              ),

                              // ❤️ Add to Favorites
                              IconButton(
                                iconSize: 20,
                                tooltip: "Add to Favorites",
                                icon: const Icon(Icons.favorite_border,
                                    color: Colors.red),
                                onPressed: () async {
                                  final ayahData = {
                                    'surah_number': widget.surahNumber,
                                    'ayah_number': ayah['ayah_number'],
                                    'text_ar': ayah['text_ar'] ?? "",
                                    'text_mn': ayah['text_mn'] ?? "",
                                    'translation_tl':
                                    ayah['translation_tl'] ?? "",
                                    'translation_bis':
                                    ayah['translation_bis'] ?? "",
                                    'translation_en':
                                    ayah['translation_en'] ?? "",
                                  };

                                  await BookmarkManager.addFavorite(
                                      ayahData);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Added to Favorites",
                                          style: GoogleFonts.merriweather(),
                                        ),
                                        duration:
                                        const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),

                              // ▶️ / ⏸
                              IconButton(
                                iconSize: 22,
                                tooltip:
                                isThisPlaying ? "Pause" : "Play",
                                icon: Icon(
                                  isThisPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (isThisPlaying) {
                                    _pauseAudio();
                                  } else {
                                    _playAyah(ayah['ayah_number'],
                                        index: index);
                                  }
                                },
                              ),

                              // 🔁 Repeat
                              IconButton(
                                iconSize: 22,
                                tooltip: "Repeat",
                                icon: Icon(
                                  repeatAyah
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                  color: repeatAyah || repeatSurah
                                      ? Colors.greenAccent
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (!repeatAyah && !repeatSurah) {
                                      repeatAyah = true;
                                      repeatSurah = false;
                                    } else if (repeatAyah) {
                                      repeatAyah = false;
                                      repeatSurah = true;
                                    } else {
                                      repeatAyah = false;
                                      repeatSurah = false;
                                    }
                                  });
                                },
                              ),

                              // 👁 Toggle
                              IconButton(
                                iconSize: 22,
                                tooltip: isExpanded
                                    ? "Hide Translation"
                                    : "Show Translation",
                                icon: Icon(
                                  isExpanded
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedAyahIndex =
                                    isExpanded ? null : index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
