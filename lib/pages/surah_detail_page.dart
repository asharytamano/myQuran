import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../utils/bookmark_manager.dart';
import '../utils/translation_loader.dart';
import '../utils/surah_info_loader.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;

  // ✅ add this
  final int? initialAyahNumber;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    this.initialAyahNumber, // ✅ add this
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayahs = [];
  bool loading = true;

  String selectedReciter = "sudais";
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ✅ Replace with ScrollablePositionedList controllers
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  // Remove old scroll controller and keys
  // final ScrollController _scrollController = ScrollController();
  // List<GlobalKey> _itemKeys = [];

  int? currentlyPlayingAyah;
  bool isPlaying = false;
  bool continuousPlay = true;
  int? expandedAyahIndex;

  // repeat mode
  bool repeatAyah = false;
  bool repeatSurah = false;

  // language toggle - changed to tagalog as default
  String selectedLanguage = "tagalog";

  // controls Surah Info box
  bool showOverview = true;

  // prevents end-of-surah repeat
  bool alreadyEnded = false;

  // ✅ prevents multiple initial scroll jumps on desktop/web
  bool _didInitialJump = false;

  // ✅ Added: Go to Ayah controller
  final TextEditingController _goToAyahCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSurah();
    _loadReciterPref();
    _loadLanguagePref(); // ✅ load language preference

    _audioPlayer.onPlayerComplete.listen((_) {
      if (currentlyPlayingAyah != null) {
        if (repeatAyah) {
          _playAyah(
            ayahs[currentlyPlayingAyah!]['ayah_number'],
            index: currentlyPlayingAyah,
          );
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

  @override
  void dispose() {
    _goToAyahCtrl.dispose(); // ✅ Dispose the controller
    _audioPlayer.dispose();
    super.dispose();
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

  // ✅ NEW: load language preference
  Future<void> _loadLanguagePref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedLanguage');
    if (saved != null && mounted) {
      setState(() => selectedLanguage = saved);
    }
  }

  // ✅ NEW: save language preference
  Future<void> _saveLanguagePref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedLanguage", value);
  }

  Future<void> fetchSurah() async {
    final res = await http.get(
      Uri.parse(
        "https://maranaw.com/api/surah_json.php?surah=${widget.surahNumber}",
      ),
    );
    final data = json.decode(res.body);

    setState(() {
      ayahs = List<Map<String, dynamic>>.from(data['data']['ayahs']);

      // ✅ remove basmala marker (ayah 0)
      ayahs.removeWhere((a) => (a['ayah_number'] ?? -1) == 0);

      loading = false;
    });

    // ✅ Load translations after fetching
    await _mergeTranslation(QuranLanguage.tagalog, "translation_tl");
    await _mergeTranslation(QuranLanguage.bisayan, "translation_bis");
    await _mergeTranslation(QuranLanguage.english, "translation_en");

    // ✅ JUMP to bookmarked ayah using the new method
    final target = widget.initialAyahNumber;
    if (!_didInitialJump && target != null && ayahs.isNotEmpty) {
      _didInitialJump = true;
      await _jumpToAyahNumber(target);
    }
  }

  // ✅ NEW: Jump to Ayah Number method using ScrollablePositionedList
  Future<void> _jumpToAyahNumber(int ayahNo) async {
    if (ayahs.isEmpty) return;

    final int targetIndex = (ayahNo - 1).clamp(0, ayahs.length - 1);

    setState(() {
      expandedAyahIndex = targetIndex; // ✅ auto-open translation behavior
    });

    // scroll to index even if not built yet
    if (_itemScrollController.isAttached) {
      await _itemScrollController.scrollTo(
        index: targetIndex,
        alignment: 0.15,
        duration: const Duration(milliseconds: 1), // ✅ must be > 0
      );
    } else {
      // If not attached yet, wait a bit and try again
      await Future.delayed(const Duration(milliseconds: 100));
      if (_itemScrollController.isAttached && mounted) {
        await _itemScrollController.scrollTo(
          index: targetIndex,
          alignment: 0.15,
          duration: Duration.zero,
        );
      }
    }
  }

  // ✅ NEW: Handle Go to Ayah function
  void _handleGoToAyah() {
    final ayahNo = int.tryParse(_goToAyahCtrl.text.trim());
    if (ayahNo != null) {
      _jumpToAyahNumber(ayahNo);
    } else {
      // Show snackbar if input is not a valid number
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid number"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
        // ✅ Only auto-center on mobile devices (not desktop/web)
        final isMobile =
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS);

        if (isMobile) {
          _jumpToAyahNumber(
            ayahNumber,
          ); // Use the same jump function for centering
        }
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

  // ✅ Added: Go to Ayah bar widget
  Widget _goToAyahBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text("Go to Ayah #", style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: TextField(
              controller: _goToAyahCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "e.g. 255",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              onSubmitted: (_) => _handleGoToAyah(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _handleGoToAyah,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("GO", style: TextStyle(color: Colors.black)),
          ),

          // Optional quick button only when Surah 2 is open
          if (widget.surahNumber == 2) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                _goToAyahCtrl.text = "255";
                _handleGoToAyah();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                "Ayatul Kursi",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // ✅ Added: Go to Ayah bar (placed near the top)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: _goToAyahBar(),
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
                        value: "tagalog",
                        child: Text("Tagalog"),
                      ),
                      DropdownMenuItem(
                        value: "bisayan",
                        child: Text("Bisayan"),
                      ),
                      DropdownMenuItem(
                        value: "english",
                        child: Text("English"),
                      ),
                      DropdownMenuItem(
                        value: "maranao",
                        child: Text("Maranao"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedLanguage = val);
                        _saveLanguagePref(val); // ✅ save preference
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
                            final info =
                                snapshot.data!["${widget.surahNumber}"];
                            if (info == null) return const SizedBox();

                            return Card(
                              key: const ValueKey(
                                "overviewBox",
                              ), // 👈 important for switcher
                              color: Colors.black.withOpacity(0.75),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.orangeAccent,
                                  width: 1,
                                ),
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

                // 🔹 Ayah list WITH ScrollablePositionedList
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    itemCount: ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = ayahs[index];
                      final bool isExpanded = expandedAyahIndex == index;
                      final bool isThisPlaying =
                          index == currentlyPlayingAyah && isPlaying;

                      return Card(
                        // ✅ you can remove GlobalKey usage now (optional)
                        color: Colors.black87,
                        elevation: isThisPlaying ? 10 : 2,
                        shadowColor: isThisPlaying
                            ? Colors.orangeAccent
                            : Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isThisPlaying
                              ? const BorderSide(
                                  color: Colors.orangeAccent,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                height: 44,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // 📋 Copy
                                    IconButton(
                                      iconSize: 20,
                                      tooltip: "Copy",
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        final copyText =
                                            "${ayah['text_ar']}\n\n${selectedLanguage == "maranao"
                                                ? (ayah['text_mn'] ?? "")
                                                : selectedLanguage == "tagalog"
                                                ? (ayah['translation_tl'] ?? "—")
                                                : selectedLanguage == "bisayan"
                                                ? (ayah['translation_bis'] ?? "—")
                                                : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                                        Clipboard.setData(
                                          ClipboardData(text: copyText),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Copied to clipboard",
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),

                                    // 📤 Share
                                    IconButton(
                                      iconSize: 20,
                                      tooltip: "Share",
                                      icon: const Icon(
                                        Icons.share,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        final shareText =
                                            "${ayah['text_ar']}\n\n${selectedLanguage == "maranao"
                                                ? (ayah['text_mn'] ?? "")
                                                : selectedLanguage == "tagalog"
                                                ? (ayah['translation_tl'] ?? "—")
                                                : selectedLanguage == "bisayan"
                                                ? (ayah['translation_bis'] ?? "—")
                                                : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                                        Share.share(shareText);
                                      },
                                    ),

                                    // ❤️ Add to Favorites
                                    IconButton(
                                      iconSize: 20,
                                      tooltip: "Add to Favorites",
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        color: Colors.red,
                                      ),
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
                                          ayahData,
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Added to Favorites",
                                                style:
                                                    GoogleFonts.merriweather(),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),

                                    // ▶️ / ⏸
                                    IconButton(
                                      iconSize: 22,
                                      tooltip: isThisPlaying ? "Pause" : "Play",
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
                                          _playAyah(
                                            ayah['ayah_number'],
                                            index: index,
                                          );
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
                                          expandedAyahIndex = isExpanded
                                              ? null
                                              : index;
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
